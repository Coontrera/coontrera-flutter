import '../firebase/firebase_auth_repository.dart';
import '../firebase/firestore_agenda.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../local/hive_boxes.dart';
import '../models/app_user.dart';
import '../models/appointment.dart';
import '../models/blocked_period.dart';
import '../models/day_availability.dart';
import '../models/service.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/availability_repository.dart';
import '../repositories/mock/mock_appointment_repository.dart';
import '../repositories/mock/mock_auth_repository.dart';
import '../repositories/mock/mock_availability_repository.dart';
import '../repositories/mock/mock_service_repository.dart';
import '../repositories/service_repository.dart';

// Hive boxes are opened once in HiveBootstrap.init() (called in main()
// before runApp), so accessing Hive.box<T>() here is safe.
final _usersBoxProvider = Provider<Box<AppUser>>((ref) => Hive.box<AppUser>(HiveBoxes.users));
final _appointmentsBoxProvider =
    Provider<Box<Appointment>>((ref) => Hive.box<Appointment>(HiveBoxes.appointments));
final _servicesBoxProvider =
    Provider<Box<Service>>((ref) => Hive.box<Service>(HiveBoxes.services));
final _blockedBoxProvider =
    Provider<Box<BlockedPeriod>>((ref) => Hive.box<BlockedPeriod>(HiveBoxes.blockedPeriods));
final _weeklyBoxProvider =
    Provider<Box<DayAvailability>>((ref) => Hive.box<DayAvailability>(HiveBoxes.weeklyAvailability));
final _metaBoxProvider = Provider<Box>((ref) => Hive.box(HiveBoxes.meta));

final firebaseEnabledProvider = Provider<bool>((ref) => false);
final _agendaProvider = Provider<FirestoreAgenda>((ref) => FirestoreAgenda());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ref.watch(firebaseEnabledProvider)) return FirebaseAuthRepository();
  return MockAuthRepository(
    usersBox: ref.watch(_usersBoxProvider),
    metaBox: ref.watch(_metaBoxProvider),
  );
});

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return MockServiceRepository(servicesBox: ref.watch(_servicesBoxProvider));
});

final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  if (ref.watch(firebaseEnabledProvider)) return ref.watch(_agendaProvider);
  return MockAvailabilityRepository(
    weeklyBox: ref.watch(_weeklyBoxProvider),
    blockedBox: ref.watch(_blockedBoxProvider),
    appointmentsBox: ref.watch(_appointmentsBoxProvider),
  );
});

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  if (ref.watch(firebaseEnabledProvider)) return ref.watch(_agendaProvider);
  return MockAppointmentRepository(
    appointmentsBox: ref.watch(_appointmentsBoxProvider),
    availabilityRepository: ref.watch(availabilityRepositoryProvider),
  );
});

final servicesListProvider = FutureProvider<List<Service>>((ref) {
  return ref.watch(serviceRepositoryProvider).getAll();
});
