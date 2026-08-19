import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:coontrera_mobile/data/models/app_user.dart';
import 'package:coontrera_mobile/data/models/appointment.dart';
import 'package:coontrera_mobile/data/models/appointment_status.dart';
import 'package:coontrera_mobile/data/models/blocked_period.dart';
import 'package:coontrera_mobile/data/models/day_availability.dart';
import 'package:coontrera_mobile/data/models/user_role.dart';
import 'package:coontrera_mobile/data/repositories/mock/mock_appointment_repository.dart';
import 'package:coontrera_mobile/data/repositories/mock/mock_auth_repository.dart';
import 'package:coontrera_mobile/data/repositories/mock/mock_availability_repository.dart';
import 'package:coontrera_mobile/data/repositories/repository_exceptions.dart';

void main() {
  late Directory tempDir;
  late Box<AppUser> usersBox;
  late Box<Appointment> appointmentsBox;
  late Box<BlockedPeriod> blockedBox;
  late Box<DayAvailability> weeklyBox;
  late Box metaBox;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('coontrera_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserRoleAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AppUserAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(AppointmentStatusAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(AppointmentAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(DayAvailabilityAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(BlockedPeriodAdapter());

    usersBox = await Hive.openBox<AppUser>('users');
    appointmentsBox = await Hive.openBox<Appointment>('appointments');
    blockedBox = await Hive.openBox<BlockedPeriod>('blocked');
    weeklyBox = await Hive.openBox<DayAvailability>('weekly');
    metaBox = await Hive.openBox('meta');

    // Weekday-agnostic: open every day of the week so tests don't depend on
    // which day `DateTime.now()` happens to fall on.
    for (var weekday = 1; weekday <= 7; weekday++) {
      await weeklyBox.put(
        weekday,
        DayAvailability(weekday: weekday, isOpen: true, startTime: '08:00', endTime: '18:00'),
      );
    }
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('MockAuthRepository', () {
    test('register then login succeeds with correct credentials', () async {
      final repo = MockAuthRepository(usersBox: usersBox, metaBox: metaBox);
      final user = await repo.register(
        name: 'Teste da Silva',
        email: 'teste@exemplo.com',
        password: 'senha123',
        phone: '16999990000',
      );
      expect(user.role, UserRole.client);

      final loggedIn = await repo.login('teste@exemplo.com', 'senha123');
      expect(loggedIn.id, user.id);
    });

    test('login fails with wrong password', () async {
      final repo = MockAuthRepository(usersBox: usersBox, metaBox: metaBox);
      await repo.register(
        name: 'Teste da Silva',
        email: 'teste2@exemplo.com',
        password: 'senha123',
        phone: '16999990000',
      );

      expect(
        () => repo.login('teste2@exemplo.com', 'senhaerrada'),
        throwsA(isA<AuthException>()),
      );
    });

    test('register fails for duplicate email', () async {
      final repo = MockAuthRepository(usersBox: usersBox, metaBox: metaBox);
      await repo.register(
        name: 'Primeiro',
        email: 'duplicado@exemplo.com',
        password: 'senha123',
        phone: '16999990000',
      );

      expect(
        () => repo.register(
          name: 'Segundo',
          email: 'duplicado@exemplo.com',
          password: 'outrasenha',
          phone: '16999990001',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('MockAvailabilityRepository + MockAppointmentRepository', () {
    test('booking a slot removes it from availability, and double-booking is rejected', () async {
      final availabilityRepo = MockAvailabilityRepository(
        weeklyBox: weeklyBox,
        blockedBox: blockedBox,
        appointmentsBox: appointmentsBox,
      );
      final appointmentRepo = MockAppointmentRepository(
        appointmentsBox: appointmentsBox,
        availabilityRepository: availabilityRepo,
      );

      final date = DateTime.now().add(const Duration(days: 5));
      final slotsBefore = await availabilityRepo.getAvailableSlots(date);
      final targetSlot = slotsBefore.firstWhere((s) => s.isAvailable);

      await appointmentRepo.book(
        clientId: 'client-1',
        serviceId: 'pilates',
        date: date,
        timeSlot: targetSlot.time,
      );

      final slotsAfter = await availabilityRepo.getAvailableSlots(date);
      final sameSlotAfter = slotsAfter.firstWhere((s) => s.time == targetSlot.time);
      expect(sameSlotAfter.isAvailable, isFalse);

      expect(
        () => appointmentRepo.book(
          clientId: 'client-2',
          serviceId: 'fisioterapia',
          date: date,
          timeSlot: targetSlot.time,
        ),
        throwsA(isA<BookingException>()),
      );
    });

    test('blocking a full day excludes all its slots from availability', () async {
      final availabilityRepo = MockAvailabilityRepository(
        weeklyBox: weeklyBox,
        blockedBox: blockedBox,
        appointmentsBox: appointmentsBox,
      );

      final date = DateTime.now().add(const Duration(days: 10));
      await availabilityRepo.blockDay(date, reason: 'Feriado');

      final slots = await availabilityRepo.getAvailableSlots(date);
      expect(slots, isEmpty);
    });
  });
}
