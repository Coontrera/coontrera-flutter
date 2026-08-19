import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/date_time_formatters.dart';
import '../../models/appointment.dart';
import '../../models/appointment_status.dart';
import '../../models/blocked_period.dart';
import '../../models/day_availability.dart';
import '../../models/time_slot.dart';
import '../availability_repository.dart';
import 'mock_latency.dart';

class MockAvailabilityRepository implements AvailabilityRepository {
  MockAvailabilityRepository({
    required this.weeklyBox,
    required this.blockedBox,
    required this.appointmentsBox,
  });

  final Box<DayAvailability> weeklyBox;
  final Box<BlockedPeriod> blockedBox;
  final Box<Appointment> appointmentsBox;

  static const _uuid = Uuid();

  int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _fromMinutes(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  List<BlockedPeriod> _blockedForDate(DateTime date) {
    return blockedBox.values
        .where((b) => AppDateFormat.isSameDay(b.date, date))
        .toList();
  }

  @override
  Future<List<TimeSlot>> getAvailableSlots(DateTime date) async {
    await simulateLatency();
    final day = AppDateFormat.stripTime(date);
    final dayRule = weeklyBox.get(day.weekday);

    if (dayRule == null || !dayRule.isOpen) return const [];

    final blocked = _blockedForDate(day);
    if (blocked.any((b) => b.isFullDay)) return const [];

    final bookedTimes = appointmentsBox.values
        .where(
          (a) =>
              AppDateFormat.isSameDay(a.date, day) &&
              a.status != AppointmentStatus.cancelled,
        )
        .map((a) => a.timeSlot)
        .toSet();

    final now = DateTime.now();
    final slots = <TimeSlot>[];
    var cursor = _toMinutes(dayRule.startTime);
    final end = _toMinutes(dayRule.endTime);

    while (cursor + dayRule.slotMinutes <= end) {
      final time = _fromMinutes(cursor);
      final slotDateTime = DateTime(day.year, day.month, day.day, cursor ~/ 60, cursor % 60);

      final isPast = slotDateTime.isBefore(now);
      final isBooked = bookedTimes.contains(time);
      final isBlocked = blocked.any((b) {
        if (b.isFullDay) return true;
        final blockStart = _toMinutes(b.startTime!);
        final blockEnd = _toMinutes(b.endTime!);
        return cursor >= blockStart && cursor < blockEnd;
      });

      slots.add(
        TimeSlot(
          date: day,
          time: time,
          isAvailable: !isPast && !isBooked && !isBlocked,
        ),
      );
      cursor += dayRule.slotMinutes;
    }

    return slots;
  }

  @override
  Future<List<BlockedPeriod>> getBlockedPeriods({DateTime? from, DateTime? to}) async {
    await simulateLatency();
    var items = blockedBox.values.toList();
    if (from != null) {
      items = items.where((b) => !b.date.isBefore(AppDateFormat.stripTime(from))).toList();
    }
    if (to != null) {
      items = items.where((b) => !b.date.isAfter(AppDateFormat.stripTime(to))).toList();
    }
    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  @override
  Future<BlockedPeriod> blockDay(DateTime date, {required String reason}) async {
    await simulateLatency();
    final period = BlockedPeriod(
      id: _uuid.v4(),
      date: AppDateFormat.stripTime(date),
      reason: reason,
    );
    await blockedBox.put(period.id, period);
    return period;
  }

  @override
  Future<BlockedPeriod> blockSlot(
    DateTime date,
    String startTime,
    String endTime, {
    required String reason,
  }) async {
    await simulateLatency();
    final period = BlockedPeriod(
      id: _uuid.v4(),
      date: AppDateFormat.stripTime(date),
      startTime: startTime,
      endTime: endTime,
      reason: reason,
    );
    await blockedBox.put(period.id, period);
    return period;
  }

  @override
  Future<void> unblock(String blockedPeriodId) async {
    await simulateLatency();
    await blockedBox.delete(blockedPeriodId);
  }

  @override
  Future<List<DayAvailability>> getWeeklyAvailability() async {
    await simulateLatency();
    final days = weeklyBox.values.toList();
    days.sort((a, b) => a.weekday.compareTo(b.weekday));
    return days;
  }

  @override
  Future<void> updateWeeklyAvailability(DayAvailability day) async {
    await simulateLatency();
    await weeklyBox.put(day.weekday, day);
  }

  @override
  Future<bool> isDateFullyBlocked(DateTime date) async {
    final day = AppDateFormat.stripTime(date);
    final dayRule = weeklyBox.get(day.weekday);
    if (dayRule == null || !dayRule.isOpen) return true;
    return _blockedForDate(day).any((b) => b.isFullDay);
  }
}
