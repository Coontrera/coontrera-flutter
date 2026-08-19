import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/blocked_period.dart';
import '../../../data/models/day_availability.dart';
import '../../../data/providers/repository_providers.dart';

final allAppointmentsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) {
  return ref.watch(appointmentRepositoryProvider).getAll();
});

final allClientsProvider = FutureProvider.autoDispose<List<AppUser>>((ref) {
  return ref.watch(authRepositoryProvider).getAllClients();
});

final blockedPeriodsProvider = FutureProvider.autoDispose<List<BlockedPeriod>>((ref) {
  return ref.watch(availabilityRepositoryProvider).getBlockedPeriods();
});

final weeklyAvailabilityProvider = FutureProvider.autoDispose<List<DayAvailability>>((ref) {
  return ref.watch(availabilityRepositoryProvider).getWeeklyAvailability();
});
