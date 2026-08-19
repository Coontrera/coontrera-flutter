import '../models/appointment.dart';
import '../models/appointment_status.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getForClient(String clientId);

  Future<List<Appointment>> getAll({DateTime? from, DateTime? to});

  Future<List<Appointment>> getForDate(DateTime date);

  Future<Appointment> book({
    required String clientId,
    required String serviceId,
    required DateTime date,
    required String timeSlot,
    String? notes,
  });

  Future<void> cancel(String appointmentId, {required String actorId, String? reason});

  Future<void> updateStatus(String appointmentId, AppointmentStatus status);
}
