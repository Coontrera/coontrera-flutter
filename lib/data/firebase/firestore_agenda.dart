import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';
import '../models/appointment_status.dart';
import '../models/blocked_period.dart';
import '../models/day_availability.dart';
import '../models/time_slot.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/availability_repository.dart';
import '../repositories/repository_exceptions.dart';

typedef _Doc = DocumentSnapshot<Map<String, dynamic>>;
int _day(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;
DateTime _date(int day) {
  final d = DateTime.fromMillisecondsSinceEpoch(
    day * Duration.millisecondsPerDay,
    isUtc: true,
  );
  return DateTime(d.year, d.month, d.day);
}

int _minutes(String time) {
  final parts = time.split(':');
  return int.parse(parts.first) * 60 + int.parse(parts.last);
}

String _clock(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

class FirestoreAgenda implements AppointmentRepository, AvailabilityRepository {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _visits =>
      _db.collection('appointments');
  CollectionReference<Map<String, dynamic>> get _blocks =>
      _db.collection('blocks');
  CollectionReference<Map<String, dynamic>> get _weekly =>
      _db.collection('weekly');
  DocumentReference<Map<String, dynamic>> _schedule(int day) =>
      _db.collection('days').doc('$day');

  Appointment _visit(_Doc doc) {
    final v = doc.data()!;
    return Appointment(
      id: doc.id,
      clientId: v['clientId'],
      serviceId: v['serviceId'],
      date: _date(v['day']),
      timeSlot: _clock(v['minute']),
      status: AppointmentStatus.values.byName(v['status']),
      notes: v['notes'],
      cancelReason: v['cancelReason'],
      cancelledBy: v['cancelledBy'],
      createdAt: (v['createdAt'] as Timestamp).toDate(),
    );
  }

  Query<Map<String, dynamic>> _range(
    Query<Map<String, dynamic>> query,
    DateTime? from,
    DateTime? to,
  ) {
    if (from != null) {
      query = query.where('day', isGreaterThanOrEqualTo: _day(from));
    }
    if (to != null) query = query.where('day', isLessThanOrEqualTo: _day(to));
    return query.orderBy('day');
  }

  @override
  Future<List<Appointment>> getForClient(String clientId) async {
    final result = await _visits.where('clientId', isEqualTo: clientId).get();
    return result.docs.map(_visit).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<Appointment>> getAll({DateTime? from, DateTime? to}) async =>
      (await _range(_visits, from, to).get()).docs.map(_visit).toList();
  @override
  Future<List<Appointment>> getForDate(DateTime date) =>
      getAll(from: date, to: date);

  @override
  Future<Appointment> book({
    required String clientId,
    required String serviceId,
    required DateTime date,
    required String timeSlot,
    String? notes,
  }) async {
    final id = _visits.doc();
    final day = _day(date);
    final minute = _minutes(timeSlot);
    final lock = _schedule(day).collection('slots').doc('${minute ~/ 60}');
    try {
      await _db.runTransaction((tx) async {
        if ((await tx.get(lock)).exists) {
          throw const BookingException('Horário já reservado.');
        }
        tx.set(id, {
          'clientId': clientId,
          'serviceId': serviceId,
          'day': day,
          'minute': minute,
          'notes': notes,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'pending',
        });
        tx.set(lock, {'appointment': id.id, 'minute': minute});
      });
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
      throw const BookingException(
        'Reserva recusada. Atualize os horários e tente novamente.',
      );
    }
    return Appointment(
      id: id.id,
      clientId: clientId,
      serviceId: serviceId,
      date: _date(day),
      timeSlot: timeSlot,
      notes: notes,
      createdAt: DateTime.now(),
      status: AppointmentStatus.pending,
    );
  }

  @override
  Future<void> cancel(
    String appointmentId, {
    required String actorId,
    String? reason,
  }) async {
    final ref = _visits.doc(appointmentId);
    await _db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (!doc.exists) {
        throw const BookingException('Agendamento não encontrado.');
      }
      final v = doc.data()!;
      if (v['status'] == 'cancelled') return;
      tx.update(ref, {
        'status': 'cancelled',
        'cancelledBy': actorId,
        'cancelReason': reason,
      });
      tx.delete(
        _schedule(v['day']).collection('slots').doc("${v['minute'] ~/ 60}"),
      );
    });
  }

  @override
  Future<void> updateStatus(String appointmentId, AppointmentStatus status) =>
      status == AppointmentStatus.cancelled
      ? cancel(appointmentId, actorId: FirebaseAuth.instance.currentUser!.uid)
      : _visits.doc(appointmentId).update({'status': status.name});

  DayAvailability _hours(int weekday, Map<String, dynamic>? v) =>
      DayAvailability(
        weekday: weekday,
        isOpen: v?['open'] ?? weekday <= 5,
        startTime: _clock(v?['start'] ?? 480),
        endTime: _clock(v?['end'] ?? 1080),
        slotMinutes: v?['step'] ?? 60,
      );

  @override
  Future<List<DayAvailability>> getWeeklyAvailability() async {
    final docs = (await _weekly.get()).docs;
    final data = {for (final d in docs) d.id: d.data()};
    return [for (var i = 1; i <= 7; i++) _hours(i, data['$i'])];
  }

  @override
  Future<void> updateWeeklyAvailability(DayAvailability day) =>
      _weekly.doc('${day.weekday}').set({
        'open': day.isOpen,
        'start': _minutes(day.startTime),
        'end': _minutes(day.endTime),
        'step': day.slotMinutes,
      });

  @override
  Future<List<TimeSlot>> getAvailableSlots(DateTime date) async {
    final day = _day(date);
    final hours = _hours(
      date.weekday,
      (await _weekly.doc('${date.weekday}').get()).data(),
    );
    if (!hours.isOpen) return [];
    final ref = _schedule(day);
    final data = (await ref.get()).data();
    if (data?['closed'] == true) return [];
    final blocked = Set<int>.from(data?['minutes'] ?? []);
    final taken = (await ref.collection('slots').get()).docs
        .map((d) => d.data()['minute'] as int)
        .toSet();
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      for (
        var m = _minutes(hours.startTime);
        m + hours.slotMinutes <= _minutes(hours.endTime);
        m += hours.slotMinutes
      )
        TimeSlot(
          date: date,
          time: _clock(m),
          isAvailable:
              !blocked.contains(m) &&
              !taken.any((start) => (start - m).abs() < 60) &&
              (day * 1440 + m + 180) * 60000 > now,
        ),
    ];
  }

  @override
  Future<bool> isDateFullyBlocked(DateTime date) async =>
      (await getAvailableSlots(date)).isEmpty;

  BlockedPeriod _block(_Doc doc) {
    final b = doc.data()!;
    return BlockedPeriod(
      id: doc.id,
      date: _date(b['day']),
      reason: b['reason'],
      startTime: b['start'],
      endTime: b['end'],
    );
  }

  @override
  Future<List<BlockedPeriod>> getBlockedPeriods({
    DateTime? from,
    DateTime? to,
  }) async => (await _range(_blocks, from, to).get()).docs.map(_block).toList();

  // As exceções podem se sobrepor. Recalcular a união mantém os demais bloqueios ao remover um deles.
  void _writeDay(
    Transaction tx,
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> ranges,
  ) {
    final minutes = <int>{};
    var closed = false;
    for (final range in ranges.values) {
      if (range['start'] == null) {
        closed = true;
        continue;
      }
      for (
        var m = (_minutes(range['start']) - 59).clamp(0, 1439);
        m < _minutes(range['end']);
        m++
      ) {
        minutes.add(m);
      }
    }
    tx.set(ref, {
      'ranges': ranges,
      'closed': closed,
      'minutes': minutes.toList(),
    });
  }

  Future<BlockedPeriod> _add(
    DateTime date,
    String? start,
    String? end,
    String reason,
  ) async {
    final block = _blocks.doc();
    final day = _day(date);
    final ref = _schedule(day);
    await _db.runTransaction((tx) async {
      final ranges = Map<String, dynamic>.from(
        (await tx.get(ref)).data()?['ranges'] ?? {},
      );
      final range = {'start': start, 'end': end};
      ranges[block.id] = range;
      _writeDay(tx, ref, ranges);
      tx.set(block, {'day': day, 'reason': reason, ...range});
    });
    return BlockedPeriod(
      id: block.id,
      date: date,
      startTime: start,
      endTime: end,
      reason: reason,
    );
  }

  @override
  Future<BlockedPeriod> blockDay(DateTime date, {required String reason}) =>
      _add(date, null, null, reason);
  @override
  Future<BlockedPeriod> blockSlot(
    DateTime date,
    String startTime,
    String endTime, {
    required String reason,
  }) => _add(date, startTime, endTime, reason);
  @override
  Future<void> unblock(String blockedPeriodId) async {
    final block = _blocks.doc(blockedPeriodId);
    await _db.runTransaction((tx) async {
      final doc = await tx.get(block);
      if (!doc.exists) return;
      final ref = _schedule(doc.data()!['day']);
      final ranges = Map<String, dynamic>.from(
        (await tx.get(ref)).data()?['ranges'] ?? {},
      );
      ranges.remove(block.id);
      _writeDay(tx, ref, ranges);
      tx.delete(block);
    });
  }
}
