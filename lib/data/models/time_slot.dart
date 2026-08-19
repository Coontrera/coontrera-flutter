/// Computed availability result for a single date — not persisted.
class TimeSlot {
  const TimeSlot({required this.date, required this.time, required this.isAvailable});

  final DateTime date;

  /// 24h "HH:mm".
  final String time;

  final bool isAvailable;
}
