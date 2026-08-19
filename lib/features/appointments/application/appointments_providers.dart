import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/appointment.dart';
import '../../../data/providers/repository_providers.dart';
import '../../auth/application/auth_controller.dart';

final clientAppointmentsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) async {
  final user = ref.watch(authControllerProvider).valueOrNull;
  if (user == null) return const [];
  return ref.watch(appointmentRepositoryProvider).getForClient(user.id);
});
