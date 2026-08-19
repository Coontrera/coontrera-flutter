import 'package:hive/hive.dart';

part 'appointment_status.g.dart';

@HiveType(typeId: 2)
enum AppointmentStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  confirmed,
  @HiveField(2)
  cancelled,
  @HiveField(3)
  completed,
}
