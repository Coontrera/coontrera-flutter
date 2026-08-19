import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_time_formatters.dart';

class BlockPeriodResult {
  const BlockPeriodResult({
    required this.date,
    required this.reason,
    this.startTime,
    this.endTime,
  });

  final DateTime date;
  final String reason;
  final String? startTime;
  final String? endTime;
}

Future<BlockPeriodResult?> showBlockDayDialog(BuildContext context) {
  return showDialog<BlockPeriodResult>(
    context: context,
    builder: (context) => const _BlockDayDialog(),
  );
}

class _BlockDayDialog extends StatefulWidget {
  const _BlockDayDialog();

  @override
  State<_BlockDayDialog> createState() => _BlockDayDialogState();
}

class _BlockDayDialogState extends State<_BlockDayDialog> {
  DateTime _date = DateTime.now();
  bool _fullDay = true;
  TimeOfDay _start = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 18, minute: 0);
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked != null) {
      setState(() => isStart ? _start = picked : _end = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bloquear data'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data'),
              subtitle: Text(AppDateFormat.dayMonthYear.format(_date)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bloquear dia inteiro'),
              value: _fullDay,
              onChanged: (v) => setState(() => _fullDay = v),
            ),
            if (!_fullDay) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Início'),
                subtitle: Text(_fmt(_start)),
                onTap: () => _pickTime(true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fim'),
                subtitle: Text(_fmt(_end)),
                onTap: () => _pickTime(false),
              ),
            ],
            const SizedBox(height: AppSpace.sm),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                hintText: 'Ex: Feriado, ausência da equipe',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            final reason = _reasonController.text.trim();
            Navigator.of(context).pop(
              BlockPeriodResult(
                date: _date,
                reason: reason.isEmpty ? 'Bloqueado pelo administrador' : reason,
                startTime: _fullDay ? null : _fmt(_start),
                endTime: _fullDay ? null : _fmt(_end),
              ),
            );
          },
          child: const Text('Bloquear'),
        ),
      ],
    );
  }
}
