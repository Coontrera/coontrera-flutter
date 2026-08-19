import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/time_slot.dart';

class TimeSlotGrid extends StatelessWidget {
  const TimeSlotGrid({
    super.key,
    required this.slots,
    required this.selectedTime,
    required this.onSelect,
  });

  final List<TimeSlot> slots;
  final String? selectedTime;
  final void Function(String time) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (slots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.xl),
        child: Center(
          child: Text(
            'Este dia não possui horários de atendimento.',
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
      );
    }

    return Wrap(
      spacing: AppSpace.sm,
      runSpacing: AppSpace.sm,
      children: slots.map((slot) {
        final isSelected = slot.time == selectedTime;
        return ChoiceChip(
          label: Text(slot.time),
          selected: isSelected,
          onSelected: slot.isAvailable ? (_) => onSelect(slot.time) : null,
          disabledColor: colors.border.withValues(alpha: 0.4),
          labelStyle: TextStyle(
            color: !slot.isAvailable
                ? colors.textSecondary.withValues(alpha: 0.5)
                : (isSelected ? colors.onPrimary : colors.textPrimary),
            decoration: !slot.isAvailable ? TextDecoration.lineThrough : null,
          ),
          selectedColor: colors.primary,
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            side: BorderSide(color: isSelected ? colors.primary : colors.border),
          ),
        );
      }).toList(),
    );
  }
}
