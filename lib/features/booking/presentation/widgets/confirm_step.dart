import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_time_formatters.dart';
import '../../../../data/models/service.dart';

class ConfirmStep extends StatelessWidget {
  const ConfirmStep({
    super.key,
    required this.service,
    required this.date,
    required this.time,
    required this.notesController,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onConfirm,
  });

  final Service service;
  final DateTime date;
  final String time;
  final TextEditingController notesController;
  final bool isSubmitting;
  final String? errorMessage;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.lg),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: colors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumo do Agendamento', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpace.md),
                _SummaryRow(icon: Icons.spa_outlined, label: service.title),
                _SummaryRow(
                  icon: Icons.calendar_today_outlined,
                  label: AppDateFormat.dayMonthYear.format(date),
                ),
                _SummaryRow(icon: Icons.access_time, label: '$time h'),
                const _SummaryRow(
                  icon: Icons.location_on_outlined,
                  label: 'R. 9 de Julho, 795, Santa Ernestina - SP',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          TextField(
            controller: notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Observações (opcional)',
              hintText: 'Alguma informação adicional para a equipe?',
              alignLabelWithHint: true,
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpace.sm),
            Text(
              errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.danger),
            ),
          ],
          const SizedBox(height: AppSpace.lg),
          ElevatedButton(
            onPressed: isSubmitting ? null : onConfirm,
            child: isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(colors.onPrimary),
                    ),
                  )
                : const Text('Confirmar Agendamento'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: AppSpace.sm),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
