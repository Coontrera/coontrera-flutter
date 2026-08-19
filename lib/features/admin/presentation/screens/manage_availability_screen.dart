import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_time_formatters.dart';
import '../../../../data/models/day_availability.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../application/admin_providers.dart';
import '../widgets/block_day_dialog.dart';

const _weekdayNames = {
  1: 'Segunda-feira',
  2: 'Terça-feira',
  3: 'Quarta-feira',
  4: 'Quinta-feira',
  5: 'Sexta-feira',
  6: 'Sábado',
  7: 'Domingo',
};

class ManageAvailabilityScreen extends ConsumerWidget {
  const ManageAvailabilityScreen({super.key});

  Future<void> _pickTime(BuildContext context, WidgetRef ref, DayAvailability day, bool isStart) async {
    final parts = (isStart ? day.startTime : day.endTime).split(':');
    final initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    final updated = day.copyWith(
      startTime: isStart ? formatted : null,
      endTime: isStart ? null : formatted,
    );
    await ref.read(availabilityRepositoryProvider).updateWeeklyAvailability(updated);
    ref.invalidate(weeklyAvailabilityProvider);
  }

  Future<void> _toggleOpen(WidgetRef ref, DayAvailability day, bool isOpen) async {
    await ref
        .read(availabilityRepositoryProvider)
        .updateWeeklyAvailability(day.copyWith(isOpen: isOpen));
    ref.invalidate(weeklyAvailabilityProvider);
  }

  Future<void> _addBlock(BuildContext context, WidgetRef ref) async {
    final result = await showBlockDayDialog(context);
    if (result == null) return;
    final repo = ref.read(availabilityRepositoryProvider);
    if (result.startTime != null && result.endTime != null) {
      await repo.blockSlot(result.date, result.startTime!, result.endTime!, reason: result.reason);
    } else {
      await repo.blockDay(result.date, reason: result.reason);
    }
    ref.invalidate(blockedPeriodsProvider);
  }

  Future<void> _removeBlock(WidgetRef ref, String id) async {
    await ref.read(availabilityRepositoryProvider).unblock(id);
    ref.invalidate(blockedPeriodsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklyAvailabilityProvider);
    final blockedAsync = ref.watch(blockedPeriodsProvider);
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Disponibilidade')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addBlock(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Bloquear data'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          Text('Horário padrão semanal', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpace.sm),
          weeklyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Erro: $e'),
            data: (days) => Column(
              children: days.map((day) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpace.sm),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: colors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(_weekdayNames[day.weekday] ?? ''),
                        value: day.isOpen,
                        onChanged: (v) => _toggleOpen(ref, day, v),
                      ),
                      if (day.isOpen)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpace.sm),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _pickTime(context, ref, day, true),
                                  child: Text('Início: ${day.startTime}'),
                                ),
                              ),
                              const SizedBox(width: AppSpace.sm),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _pickTime(context, ref, day, false),
                                  child: Text('Fim: ${day.endTime}'),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Text('Datas bloqueadas', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpace.sm),
          blockedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Erro: $e'),
            data: (blocks) {
              if (blocks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpace.md),
                  child: Text('Nenhuma data bloqueada.'),
                );
              }
              return Column(
                children: blocks.map((b) {
                  return Dismissible(
                    key: ValueKey(b.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
                      margin: const EdgeInsets.only(bottom: AppSpace.sm),
                      decoration: BoxDecoration(
                        color: colors.danger,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    onDismissed: (_) => _removeBlock(ref, b.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppSpace.sm),
                      padding: const EdgeInsets.all(AppSpace.md),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: colors.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_busy, color: colors.danger),
                          const SizedBox(width: AppSpace.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppDateFormat.dayMonthYear.format(b.date)),
                                Text(
                                  b.isFullDay
                                      ? 'Dia inteiro · ${b.reason}'
                                      : '${b.startTime}–${b.endTime} · ${b.reason}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: AppSpace.xxl),
        ],
      ),
    );
  }
}
