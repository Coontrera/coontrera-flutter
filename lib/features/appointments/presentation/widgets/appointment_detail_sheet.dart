import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_time_formatters.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/models/appointment_status.dart';
import '../../../../data/models/service.dart';
import 'appointment_status_badge.dart';

/// Bottom sheet with appointment details and a cancel action, used by the
/// client's "My Appointments" screen.
Future<void> showAppointmentDetailSheet({
  required BuildContext context,
  required Appointment appointment,
  required Service? service,
  required Future<void> Function(String reason) onCancel,
}) {
  final canCancel = appointment.isUpcoming && !appointment.date.isBefore(
        AppDateFormat.stripTime(DateTime.now()),
      );

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _AppointmentDetailContent(
      appointment: appointment,
      service: service,
      canCancel: canCancel,
      onCancel: onCancel,
    ),
  );
}

class _AppointmentDetailContent extends StatefulWidget {
  const _AppointmentDetailContent({
    required this.appointment,
    required this.service,
    required this.canCancel,
    required this.onCancel,
  });

  final Appointment appointment;
  final Service? service;
  final bool canCancel;
  final Future<void> Function(String reason) onCancel;

  @override
  State<_AppointmentDetailContent> createState() => _AppointmentDetailContentState();
}

class _AppointmentDetailContentState extends State<_AppointmentDetailContent> {
  bool _isCancelling = false;

  Future<void> _confirmCancel() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const _CancelReasonDialog(),
    );
    if (reason == null || !mounted) return;
    setState(() => _isCancelling = true);
    try {
      await widget.onCancel(reason);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível atualizar a consulta. Confira sua conexão e tente novamente.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final appointment = widget.appointment;
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
                AppointmentStatusBadge(status: appointment.status),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            _DetailRow(icon: Icons.calendar_today_outlined,
                label: AppDateFormat.dayMonthYear.format(appointment.date)),
            _DetailRow(icon: Icons.access_time, label: '${appointment.timeSlot} h'),
            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              _DetailRow(icon: Icons.notes_outlined, label: appointment.notes!),
            if (appointment.status == AppointmentStatus.cancelled &&
                appointment.cancelReason != null)
              _DetailRow(
                icon: Icons.info_outline,
                label: 'Motivo do cancelamento: ${appointment.cancelReason}',
              ),
            const SizedBox(height: AppSpace.lg),
            if (widget.canCancel)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isCancelling ? null : _confirmCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.danger,
                    side: BorderSide(color: colors.danger),
                  ),
                  icon: _isCancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar Agendamento'),
                ),
              ),
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

class _CancelReasonDialog extends StatefulWidget {
  const _CancelReasonDialog();

  @override
  State<_CancelReasonDialog> createState() => _CancelReasonDialogState();
}

class _CancelReasonDialogState extends State<_CancelReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancelar agendamento?'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Motivo (opcional)',
          hintText: 'Ex: imprevisto pessoal',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Voltar')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: context.colors.danger),
          onPressed: () => Navigator.of(context).pop(
            _controller.text.trim().isEmpty ? 'Cancelado pelo cliente' : _controller.text.trim(),
          ),
          child: const Text('Confirmar Cancelamento'),
        ),
      ],
    );
  }
}
