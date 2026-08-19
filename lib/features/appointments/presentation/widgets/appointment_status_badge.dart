import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/appointment_status.dart';

class AppointmentStatusBadge extends StatelessWidget {
  const AppointmentStatusBadge({super.key, required this.status});

  final AppointmentStatus status;

  (Color, String) _styleFor(AppointmentStatus status, AppColorsExtension colors) {
    switch (status) {
      case AppointmentStatus.pending:
        return (colors.warning, 'Pendente');
      case AppointmentStatus.confirmed:
        return (colors.success, 'Confirmado');
      case AppointmentStatus.cancelled:
        return (colors.danger, 'Cancelado');
      case AppointmentStatus.completed:
        return (colors.textSecondary, 'Concluído');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, label) = _styleFor(status, context.colors);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
