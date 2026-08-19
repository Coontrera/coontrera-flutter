import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coontrera_mobile/core/theme/app_theme.dart';
import 'package:coontrera_mobile/data/models/appointment_status.dart';
import 'package:coontrera_mobile/features/appointments/presentation/widgets/appointment_status_badge.dart';

void main() {
  testWidgets('AppointmentStatusBadge shows the correct label per status', (tester) async {
    for (final entry in {
      AppointmentStatus.pending: 'Pendente',
      AppointmentStatus.confirmed: 'Confirmado',
      AppointmentStatus.cancelled: 'Cancelado',
      AppointmentStatus.completed: 'Concluído',
    }.entries) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: AppointmentStatusBadge(status: entry.key)),
        ),
      );
      expect(find.text(entry.value), findsOneWidget);
    }
  });
}
