import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/models/appointment_status.dart';
import '../../../../data/models/service.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../application/appointments_providers.dart';
import '../widgets/appointment_card.dart';
import '../widgets/appointment_detail_sheet.dart';

class MyAppointmentsScreen extends ConsumerStatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  ConsumerState<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends ConsumerState<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cancel(Appointment appointment, String reason) async {
    final user = ref.read(appointmentRepositoryProvider);
    await user.cancel(appointment.id, actorId: appointment.clientId, reason: reason);
    ref.invalidate(clientAppointmentsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(clientAppointmentsProvider);
    final servicesAsync = ref.watch(servicesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Próximos'), Tab(text: 'Histórico')],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.book),
        icon: const Icon(Icons.add),
        label: const Text('Agendar'),
      ),
      body: appointmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro ao carregar agendamentos: $e')),
        data: (appointments) {
          final services = servicesAsync.valueOrNull ?? const <Service>[];
          final servicesById = {for (final s in services) s.id: s};

          final upcoming = appointments.where((a) => a.isUpcoming).toList()
            ..sort((a, b) => a.date.compareTo(b.date));
          final history = appointments
              .where(
                (a) =>
                    a.status == AppointmentStatus.completed ||
                    a.status == AppointmentStatus.cancelled,
              )
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          return TabBarView(
            controller: _tabController,
            children: [
              _AppointmentsList(
                appointments: upcoming,
                servicesById: servicesById,
                onCancel: _cancel,
                emptyTitle: 'Nenhum agendamento futuro',
                emptyMessage: 'Que tal agendar sua próxima sessão?',
              ),
              _AppointmentsList(
                appointments: history,
                servicesById: servicesById,
                onCancel: _cancel,
                emptyTitle: 'Nenhum histórico ainda',
                emptyMessage: 'Seus agendamentos concluídos ou cancelados aparecerão aqui.',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AppointmentsList extends StatelessWidget {
  const _AppointmentsList({
    required this.appointments,
    required this.servicesById,
    required this.onCancel,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final List<Appointment> appointments;
  final Map<String, Service> servicesById;
  final Future<void> Function(Appointment, String) onCancel;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return EmptyState(
        icon: Icons.event_note_outlined,
        title: emptyTitle,
        message: emptyMessage,
        actionLabel: 'Agendar consulta',
        onAction: () => context.push(RoutePaths.book),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpace.lg),
      itemCount: appointments.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpace.sm),
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final service = servicesById[appointment.serviceId];
        return AppointmentCard(
          appointment: appointment,
          service: service,
          onTap: () => showAppointmentDetailSheet(
            context: context,
            appointment: appointment,
            service: service,
            onCancel: (reason) => onCancel(appointment, reason),
          ),
        );
      },
    );
  }
}
