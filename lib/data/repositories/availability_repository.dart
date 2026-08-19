import '../models/blocked_period.dart';
import '../models/day_availability.dart';
import '../models/time_slot.dart';

abstract class AvailabilityRepository {
  Future<List<TimeSlot>> getAvailableSlots(DateTime date);

  Future<List<BlockedPeriod>> getBlockedPeriods({DateTime? from, DateTime? to});

  Future<BlockedPeriod> blockDay(DateTime date, {required String reason});

  Future<BlockedPeriod> blockSlot(
    DateTime date,
    String startTime,
    String endTime, {
    required String reason,
  });

  Future<void> unblock(String blockedPeriodId);

  Future<List<DayAvailability>> getWeeklyAvailability();

  Future<void> updateWeeklyAvailability(DayAvailability day);

  Future<bool> isDateFullyBlocked(DateTime date);
}
