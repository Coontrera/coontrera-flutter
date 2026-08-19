import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/password_hasher.dart';
import '../models/app_user.dart';
import '../models/appointment.dart';
import '../models/appointment_status.dart';
import '../models/day_availability.dart';
import '../models/service.dart';
import '../models/user_role.dart';
import 'hive_boxes.dart';
import 'seed_data.dart';

/// Seeds demo/mock data once on first launch, guarded by [MetaKeys.seeded]
/// so re-launching the app never duplicates records.
class SeedService {
  SeedService({
    required this.usersBox,
    required this.appointmentsBox,
    required this.servicesBox,
    required this.weeklyBox,
    required this.metaBox,
  });

  final Box<AppUser> usersBox;
  final Box<Appointment> appointmentsBox;
  final Box<Service> servicesBox;
  final Box<DayAvailability> weeklyBox;
  final Box metaBox;

  static const _uuid = Uuid();

  Future<void> seedIfNeeded() async {
    if (metaBox.get(MetaKeys.seeded) == true) return;

    for (final service in SeedData.services()) {
      await servicesBox.put(service.id, service);
    }

    for (var weekday = 1; weekday <= 7; weekday++) {
      final isWeekend = weekday == 6 || weekday == 7;
      await weeklyBox.put(
        weekday,
        DayAvailability(
          weekday: weekday,
          isOpen: !isWeekend,
          startTime: '08:00',
          endTime: '18:00',
          slotMinutes: 60,
        ),
      );
    }

    final adminSalt = PasswordHasher.generateSalt();
    final admin = AppUser(
      id: 'admin-1',
      name: 'Administrador Coontrera',
      email: 'admin@coontrera.com',
      phone: '(16) 99459-3131',
      passwordHash: PasswordHasher.hash('Admin@123', adminSalt),
      passwordSalt: adminSalt,
      role: UserRole.admin,
      createdAt: DateTime.now(),
    );
    await usersBox.put(admin.id, admin);

    final clientSalt = PasswordHasher.generateSalt();
    final client = AppUser(
      id: 'client-1',
      name: 'Ana Beatriz',
      email: 'cliente@coontrera.com',
      phone: '(16) 99123-4567',
      passwordHash: PasswordHasher.hash('Cliente@123', clientSalt),
      passwordSalt: clientSalt,
      role: UserRole.client,
      createdAt: DateTime.now(),
    );
    await usersBox.put(client.id, client);

    final extraClients = [
      ('client-2', 'Maria Silva', 'maria.silva@example.com', '(16) 99876-5432'),
      ('client-3', 'João Pereira', 'joao.pereira@example.com', '(16) 99654-3210'),
      ('client-4', 'Carla Souza', 'carla.souza@example.com', '(16) 99321-6547'),
    ];
    for (final (id, name, email, phone) in extraClients) {
      final salt = PasswordHasher.generateSalt();
      await usersBox.put(
        id,
        AppUser(
          id: id,
          name: name,
          email: email,
          phone: phone,
          passwordHash: PasswordHasher.hash('Cliente@123', salt),
          passwordSalt: salt,
          role: UserRole.client,
          createdAt: DateTime.now(),
        ),
      );
    }

    final now = DateTime.now();
    DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

    final sampleAppointments = <Appointment>[
      Appointment(
        id: _uuid.v4(),
        clientId: 'client-1',
        serviceId: 'pilates',
        date: dateOnly(now.subtract(const Duration(days: 7))),
        timeSlot: '09:00',
        status: AppointmentStatus.completed,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Appointment(
        id: _uuid.v4(),
        clientId: 'client-1',
        serviceId: 'fisioterapia',
        date: dateOnly(now.add(const Duration(days: 3))),
        timeSlot: '10:00',
        status: AppointmentStatus.confirmed,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Appointment(
        id: _uuid.v4(),
        clientId: 'client-1',
        serviceId: 'quiropraxia',
        date: dateOnly(now.add(const Duration(days: 9))),
        timeSlot: '14:00',
        status: AppointmentStatus.pending,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Appointment(
        id: _uuid.v4(),
        clientId: 'client-2',
        serviceId: 'hidroterapia',
        date: dateOnly(now.add(const Duration(days: 1))),
        timeSlot: '11:00',
        status: AppointmentStatus.confirmed,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Appointment(
        id: _uuid.v4(),
        clientId: 'client-3',
        serviceId: 'liberacao',
        date: dateOnly(now.add(const Duration(days: 2))),
        timeSlot: '16:00',
        status: AppointmentStatus.pending,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      Appointment(
        id: _uuid.v4(),
        clientId: 'client-4',
        serviceId: 'dryneedling',
        date: dateOnly(now.subtract(const Duration(days: 3))),
        timeSlot: '15:00',
        status: AppointmentStatus.cancelled,
        createdAt: now.subtract(const Duration(days: 5)),
        cancelReason: 'Imprevisto pessoal',
        cancelledBy: 'client-4',
      ),
    ];
    for (final appt in sampleAppointments) {
      await appointmentsBox.put(appt.id, appt);
    }

    await metaBox.put(MetaKeys.seeded, true);
  }
}
