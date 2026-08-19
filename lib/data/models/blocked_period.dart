import 'package:hive/hive.dart';

part 'blocked_period.g.dart';

/// An admin-managed exception to the default weekly hours: a full day off
/// (startTime/endTime both null) or a partial block within a day.
@HiveType(typeId: 6)
class BlockedPeriod extends HiveObject {
  BlockedPeriod({
    required this.id,
    required this.date,
    this.startTime,
    this.endTime,
    required this.reason,
  });

  @HiveField(0)
  String id;

  /// Date-only (midnight).
  @HiveField(1)
  DateTime date;

  /// 24h "HH:mm", null when the whole day is blocked.
  @HiveField(2)
  String? startTime;

  /// 24h "HH:mm", null when the whole day is blocked.
  @HiveField(3)
  String? endTime;

  @HiveField(4)
  String reason;

  bool get isFullDay => startTime == null && endTime == null;
}
