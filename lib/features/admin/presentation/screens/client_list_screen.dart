import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../data/models/app_user.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/models/service.dart';
import '../../../../data/providers/repository_providers.dart';
import '../../application/admin_providers.dart';
import '../../../appointments/presentation/widgets/appointment_card.dart';

class ClientListScreen extends ConsumerStatefulWidget {
  const ClientListScreen({super.key});

  @override
  ConsumerState<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends ConsumerState<ClientListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(AppUser client, List<Appointment> appointments, Map<String, Service> servicesById) {
    final clientAppointments = appointments.where((a) => a.clientId == client.id).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(client.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(client.email, style: Theme.of(context).textTheme.bodyMedium),
              Text(client.phone, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpace.md),
              Text('Histórico de agendamentos', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpace.sm),
              if (clientAppointments.isEmpty)
                const Text('Nenhum agendamento registrado.')
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: clientAppointments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpace.sm),
                    itemBuilder: (context, index) {
                      final appointment = clientAppointments[index];
                      return AppointmentCard(
                        appointment: appointment,
                        service: servicesById[appointment.serviceId],
                        onTap: () {},
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(allClientsProvider);
    final appointmentsAsync = ref.watch(allAppointmentsProvider);
    final servicesAsync = ref.watch(servicesListProvider);
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Buscar por nome, e-mail ou telefone',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Expanded(
              child: clientsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Erro ao carregar clientes: $e')),
                data: (clients) {
                  final appointments = appointmentsAsync.valueOrNull ?? const <Appointment>[];
                  final servicesById = {
                    for (final s in servicesAsync.valueOrNull ?? const <Service>[]) s.id: s,
                  };
                  final counts = <String, int>{};
                  for (final a in appointments) {
                    counts[a.clientId] = (counts[a.clientId] ?? 0) + 1;
                  }

                  final filtered = clients.where((c) {
                    if (_query.isEmpty) return true;
                    return c.name.toLowerCase().contains(_query) ||
                        c.email.toLowerCase().contains(_query) ||
                        c.phone.toLowerCase().contains(_query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const EmptyState(
                      icon: Icons.people_outline,
                      title: 'Nenhum cliente encontrado',
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpace.sm),
                    itemBuilder: (context, index) {
                      final client = filtered[index];
                      return Material(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          onTap: () => _openDetail(client, appointments, servicesById),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpace.md),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: colors.cardShadow,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: colors.accent.withValues(alpha: 0.3),
                                  child: Text(
                                    client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                                    style: TextStyle(color: colors.primary),
                                  ),
                                ),
                                const SizedBox(width: AppSpace.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(client.name, style: Theme.of(context).textTheme.titleMedium),
                                      Text(client.email, style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${counts[client.id] ?? 0}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text('agend.', style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
