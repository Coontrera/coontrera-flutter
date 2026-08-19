import 'package:hive/hive.dart';

part 'day_availability.g.dart';

/// Default weekly opening hours for one weekday (1=Monday..7=Sunday, per
/// DateTime.weekday), edited by the admin in "Gerenciar disponibilidade".
@HiveType(typeId: 5)
class DayAvailability extends HiveObject {
  DayAvailability({
    required this.weekday,
    required this.isOpen,
    required this.startTime,
    required this.endTime,
    this.slotMinutes = 60,
  });

  @HiveField(0)
  int weekday;

  @HiveField(1)
  bool isOpen;

  /// 24h "HH:mm".
  @HiveField(2)
  String startTime;

  /// 24h "HH:mm".
  @HiveField(3)
  String endTime;

  @HiveField(4)
  int slotMinutes;

  DayAvailability copyWith({bool? isOpen, String? startTime, String? endTime}) {
    return DayAvailability(
      weekday: weekday,
      isOpen: isOpen ?? this.isOpen,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      slotMinutes: slotMinutes,
    );
  }
}
