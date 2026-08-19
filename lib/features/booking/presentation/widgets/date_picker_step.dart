import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_time_formatters.dart';

class DatePickerStep extends StatefulWidget {
  const DatePickerStep({super.key, required this.selectedDate, required this.onDateSelected});

  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;

  @override
  State<DatePickerStep> createState() => _DatePickerStepState();
}

class _DatePickerStepState extends State<DatePickerStep> {
  late DateTime _focusedDay = widget.selectedDate ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    final today = AppDateFormat.stripTime(DateTime.now());
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.all(AppSpace.lg),
      padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: colors.cardShadow,
      ),
      child: TableCalendar(
        locale: 'pt_BR',
        firstDay: today,
        lastDay: today.add(const Duration(days: 90)),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
        selectedDayPredicate: (day) =>
            widget.selectedDate != null && AppDateFormat.isSameDay(day, widget.selectedDate!),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() => _focusedDay = focusedDay);
          widget.onDateSelected(selectedDay);
        },
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          todayDecoration: BoxDecoration(
            color: colors.accent,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(color: colors.textSecondary),
          defaultTextStyle: TextStyle(color: colors.textPrimary),
        ),
      ),
    );
  }
}
