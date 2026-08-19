import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/date_time_formatters.dart';
import '../../models/appointment.dart';
import '../../models/appointment_status.dart';
import '../appointment_repository.dart';
import '../availability_repository.dart';
import '../repository_exceptions.dart';
import 'mock_latency.dart';

class MockAppointmentRepository implements AppointmentRepository {
  MockAppointmentRepository({
    required this.appointmentsBox,
    required this.availabilityRepository,
  });

  final Box<Appointment> appointmentsBox;
  final AvailabilityRepository availabilityRepository;

  static const _uuid = Uuid();

  @override
  Future<List<Appointment>> getForClient(String clientId) async {
    await simulateLatency();
    final list = appointmentsBox.values.where((a) => a.clientId == clientId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<List<Appointment>> getAll({DateTime? from, DateTime? to}) async {
    await simulateLatency();
    var list = appointmentsBox.values.toList();
    if (from != null) {
      list = list.where((a) => !a.date.isBefore(AppDateFormat.stripTime(from))).toList();
    }
    if (to != null) {
      list = list.where((a) => !a.date.isAfter(AppDateFormat.stripTime(to))).toList();
    }
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  @override
  Future<List<Appointment>> getForDate(DateTime date) async {
    await simulateLatency();
    final day = AppDateFormat.stripTime(date);
    return appointmentsBox.values.where((a) => AppDateFormat.isSameDay(a.date, day)).toList();
  }

  @override
  Future<Appointment> book({
    required String clientId,
    required String serviceId,
    required DateTime date,
    required String timeSlot,
    String? notes,
  }) async {
    await simulateLatency();
    final day = AppDateFormat.stripTime(date);

    final slots = await availabilityRepository.getAvailableSlots(day);
    final matching = slots.where((s) => s.time == timeSlot);
    if (matching.isEmpty || !matching.first.isAvailable) {
      throw const BookingException(
        'Este horário não está mais disponível. Escolha outro horário.',
      );
    }

    final appointment = Appointment(
      id: _uuid.v4(),
      clientId: clientId,
      serviceId: serviceId,
      date: day,
      timeSlot: timeSlot,
      status: AppointmentStatus.pending,
      createdAt: DateTime.now(),
      notes: notes,
    );
    await appointmentsBox.put(appointment.id, appointment);
    return appointment;
  }

  @override
  Future<void> cancel(String appointmentId, {required String actorId, String? reason}) async {
    await simulateLatency();
    final appointment = appointmentsBox.get(appointmentId);
    if (appointment == null) {
      throw const BookingException('Agendamento não encontrado.');
    }
    appointment.status = AppointmentStatus.cancelled;
    appointment.cancelReason = reason;
    appointment.cancelledBy = actorId;
    await appointment.save();
  }

  @override
  Future<void> updateStatus(String appointmentId, AppointmentStatus status) async {
    await simulateLatency();
    final appointment = appointmentsBox.get(appointmentId);
    if (appointment == null) {
      throw const BookingException('Agendamento não encontrado.');
    }
    appointment.status = status;
    await appointment.save();
  }
}
