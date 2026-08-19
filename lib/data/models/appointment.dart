import 'package:hive/hive.dart';
import 'appointment_status.dart';

part 'appointment.g.dart';

@HiveType(typeId: 3)
class Appointment extends HiveObject {
  Appointment({
    required this.id,
    required this.clientId,
    required this.serviceId,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.createdAt,
    this.notes,
    this.cancelReason,
    this.cancelledBy,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String clientId;

  @HiveField(2)
  String serviceId;

  /// Date-only (midnight), the calendar day of the appointment.
  @HiveField(3)
  DateTime date;

  /// 24h "HH:mm" string, e.g. "09:00".
  @HiveField(4)
  String timeSlot;

  @HiveField(5)
  AppointmentStatus status;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  String? cancelReason;

  @HiveField(9)
  String? cancelledBy;

  bool get isUpcoming =>
      (status == AppointmentStatus.pending || status == AppointmentStatus.confirmed);
}
