import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_user.dart';
import '../models/appointment.dart';
import '../models/appointment_status.dart';
import '../models/blocked_period.dart';
import '../models/day_availability.dart';
import '../models/service.dart';
import '../models/user_role.dart';
import 'hive_boxes.dart';

abstract final class HiveBootstrap {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();

    Hive.registerAdapter(UserRoleAdapter());
    Hive.registerAdapter(AppUserAdapter());
    Hive.registerAdapter(AppointmentStatusAdapter());
    Hive.registerAdapter(AppointmentAdapter());
    Hive.registerAdapter(ServiceAdapter());
    Hive.registerAdapter(DayAvailabilityAdapter());
    Hive.registerAdapter(BlockedPeriodAdapter());

    await Future.wait([
      Hive.openBox<AppUser>(HiveBoxes.users),
      Hive.openBox<Appointment>(HiveBoxes.appointments),
      Hive.openBox<Service>(HiveBoxes.services),
      Hive.openBox<BlockedPeriod>(HiveBoxes.blockedPeriods),
      Hive.openBox<DayAvailability>(HiveBoxes.weeklyAvailability),
      Hive.openBox(HiveBoxes.meta),
    ]);

    _initialized = true;
  }
}
