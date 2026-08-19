import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/local/hive_boxes.dart';
import 'data/local/hive_bootstrap.dart';
import 'data/local/seed_service.dart';
import 'data/models/app_user.dart';
import 'data/models/appointment.dart';
import 'data/models/day_availability.dart';
import 'data/models/service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  await HiveBootstrap.init();

  final seedService = SeedService(
    usersBox: Hive.box<AppUser>(HiveBoxes.users),
    appointmentsBox: Hive.box<Appointment>(HiveBoxes.appointments),
    servicesBox: Hive.box<Service>(HiveBoxes.services),
    weeklyBox: Hive.box<DayAvailability>(HiveBoxes.weeklyAvailability),
    metaBox: Hive.box(HiveBoxes.meta),
  );
  await seedService.seedIfNeeded();

  runApp(const ProviderScope(child: CoontreraApp()));
}
