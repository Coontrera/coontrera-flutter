import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_time_formatters.dart';
import '../../../../data/models/app_user.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/models/appointment_status.dart';
import '../../../../data/models/service.dart';
import '../../../appointments/presentation/widgets/appointment_status_badge.dart';

Future<void> showAdminAppointmentDetailSheet({
  required BuildContext context,
  required Appointment appointment,
  required Service? service,
  required AppUser? client,
  required Future<void> Function(AppointmentStatus status) onUpdateStatus,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _AdminAppointmentDetailContent(
      appointment: appointment,
      service: service,
      client: client,
      onUpdateStatus: onUpdateStatus,
    ),
  );
}

class _AdminAppointmentDetailContent extends StatefulWidget {
  const _AdminAppointmentDetailContent({
    required this.appointment,
    required this.service,
    required this.client,
    required this.onUpdateStatus,
  });

  final Appointment appointment;
  final Service? service;
  final AppUser? client;
  final Future<void> Function(AppointmentStatus status) onUpdateStatus;

  @override
  State<_AdminAppointmentDetailContent> createState() => _AdminAppointmentDetailContentState();
}

class _AdminAppointmentDetailContentState extends State<_AdminAppointmentDetailContent> {
  bool _isUpdating = false;

  Future<void> _update(AppointmentStatus status) async {
    setState(() => _isUpdating = true);
    try {
      await widget.onUpdateStatus(status);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível atualizar a consulta. Confira sua conexão e tente novamente.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final appointment = widget.appointment;
    final status = appointment.status;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.service?.title ?? 'Agendamento', style: theme.textTheme.titleLarge),
                ),
                AppointmentStatusBadge(status: status),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            _DetailRow(icon: Icons.person_outline, label: widget.client?.name ?? 'Cliente'),
            if (widget.client != null)
              _DetailRow(icon: Icons.phone_outlined, label: widget.client!.phone),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: AppDateFormat.dayMonthYear.format(appointment.date),
            ),
            _DetailRow(icon: Icons.access_time, label: '${appointment.timeSlot} h'),
            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              _DetailRow(icon: Icons.notes_outlined, label: appointment.notes!),
            const SizedBox(height: AppSpace.lg),
            if (status == AppointmentStatus.pending || status == AppointmentStatus.confirmed) ...[
              Row(
                children: [
                  if (status == AppointmentStatus.pending)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUpdating ? null : () => _update(AppointmentStatus.confirmed),
                        icon: const Icon(Icons.check),
                        label: const Text('Confirmar'),
                      ),
                    ),
                  if (status == AppointmentStatus.confirmed)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUpdating ? null : () => _update(AppointmentStatus.completed),
                        icon: const Icon(Icons.task_alt),
                        label: const Text('Concluir'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isUpdating ? null : () => _update(AppointmentStatus.cancelled),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.danger,
                    side: BorderSide(color: colors.danger),
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.colors.primary),
          const SizedBox(width: AppSpace.sm),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
