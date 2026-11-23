import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'data/providers/repository_providers.dart';
import 'data/local/seed_data.dart';
import 'data/local/hive_boxes.dart';
import 'data/local/hive_bootstrap.dart';
import 'data/local/seed_service.dart';
import 'data/models/app_user.dart';
import 'data/models/appointment.dart';
import 'data/models/day_availability.dart';
import 'data/models/service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseEnabled = await initializeFirebaseIfConfigured();
  await initializeDateFormatting('pt_BR', null);
  await HiveBootstrap.init();

  if (firebaseEnabled) {
    final services = Hive.box<Service>(HiveBoxes.services);
    for (final service in SeedData.services()) {
      await services.put(service.id, service);
    }
  } else {
    final seedService = SeedService(
      usersBox: Hive.box<AppUser>(HiveBoxes.users),
      appointmentsBox: Hive.box<Appointment>(HiveBoxes.appointments),
      servicesBox: Hive.box<Service>(HiveBoxes.services),
      weeklyBox: Hive.box<DayAvailability>(HiveBoxes.weeklyAvailability),
      metaBox: Hive.box(HiveBoxes.meta),
    );
    await seedService.seedIfNeeded();
  }

  runApp(
    ProviderScope(
      overrides: [firebaseEnabledProvider.overrideWithValue(firebaseEnabled)],
      child: const CoontreraApp(),
    ),
  );
}
