import 'package:intl/intl.dart';

abstract final class AppDateFormat {
  static final DateFormat weekdayShort = DateFormat('EEE', 'pt_BR');
  static final DateFormat dayMonth = DateFormat("d 'de' MMMM", 'pt_BR');
  static final DateFormat dayMonthYear = DateFormat("d 'de' MMMM 'de' y", 'pt_BR');
  static final DateFormat weekdayDayMonth = DateFormat("EEE, d 'de' MMM", 'pt_BR');
  static final DateFormat monthYear = DateFormat('MMMM y', 'pt_BR');
  static final DateFormat shortDate = DateFormat('dd/MM/yyyy');

  static String dateOnlyKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static DateTime stripTime(DateTime date) => DateTime(date.year, date.month, date.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
