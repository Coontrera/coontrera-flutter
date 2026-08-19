import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_time_formatters.dart';
import '../../../../data/models/app_user.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/models/appointment_status.dart';
import '../../../../data/models/service.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../application/admin_providers.dart';
import '../widgets/admin_appointment_detail_sheet.dart';
import '../widgets/day_appointments_list.dart';

class AdminCalendarScreen extends ConsumerStatefulWidget {
  const AdminCalendarScreen({super.key});

  @override
  ConsumerState<AdminCalendarScreen> createState() => _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends ConsumerState<AdminCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Future<void> _updateStatus(Appointment appointment, AppointmentStatus status) async {
    await ref.read(appointmentRepositoryProvider).updateStatus(appointment.id, status);
    ref.invalidate(allAppointmentsProvider);
  }

  void _openDay(
    DateTime day,
    List<Appointment> dayAppointments,
    Map<String, Service> servicesById,
    Map<String, AppUser> clientsById,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DayAppointmentsList(
        date: day,
        appointments: dayAppointments,
        servicesById: servicesById,
        clientsById: clientsById,
        onTapAppointment: (appointment) {
          Navigator.of(context).pop();
          showAdminAppointmentDetailSheet(
            context: context,
            appointment: appointment,
            service: servicesById[appointment.serviceId],
            client: clientsById[appointment.clientId],
            onUpdateStatus: (status) => _updateStatus(appointment, status),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(allAppointmentsProvider);
    final servicesAsync = ref.watch(servicesListProvider);
    final clientsAsync = ref.watch(allClientsProvider);
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda da Clínica')),
      body: appointmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro ao carregar agenda: $e')),
        data: (appointments) {
          final servicesById = {
            for (final s in servicesAsync.valueOrNull ?? const <Service>[]) s.id: s,
          };
          final clientsById = {
            for (final c in clientsAsync.valueOrNull ?? const <AppUser>[]) c.id: c,
          };

          final byDay = <DateTime, List<Appointment>>{};
          for (final a in appointments) {
            final day = AppDateFormat.stripTime(a.date);
            (byDay[day] ??= []).add(a);
          }

          final selected = _selectedDay ?? _focusedDay;
          final selectedAppointments = byDay[AppDateFormat.stripTime(selected)] ?? const [];

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(AppSpace.lg),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: colors.cardShadow,
                ),
                child: TableCalendar<Appointment>(
                  locale: 'pt_BR',
                  firstDay: DateTime(DateTime.now().year - 1),
                  lastDay: DateTime(DateTime.now().year + 1),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) =>
                      _selectedDay != null && AppDateFormat.isSameDay(day, _selectedDay!),
                  eventLoader: (day) => byDay[AppDateFormat.stripTime(day)] ?? const [],
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _openDay(
                      AppDateFormat.stripTime(selectedDay),
                      byDay[AppDateFormat.stripTime(selectedDay)] ?? const [],
                      servicesById,
                      clientsById,
                    );
                  },
                  onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    markerDecoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                    defaultTextStyle: TextStyle(color: colors.textPrimary),
                    weekendTextStyle: TextStyle(color: colors.textSecondary),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${AppDateFormat.dayMonthYear.format(selected)} · '
                    '${selectedAppointments.length} agendamento(s)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.sm),
            ],
          );
        },
      ),
    );
  }
}
