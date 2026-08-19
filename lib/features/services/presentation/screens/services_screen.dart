import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../data/models/service.dart';
import '../../../../data/providers/repository_providers.dart';
import '../widgets/service_detail_section.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(String serviceId) {
    final key = _sectionKeys[serviceId];
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesListProvider);

    return Scaffold(
      appBar: const AppTopBar(),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro ao carregar serviços: $e')),
        data: (services) {
          for (final s in services) {
            _sectionKeys.putIfAbsent(s.id, () => GlobalKey());
          }
          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.lg, AppSpace.lg, AppSpace.md),
                  child: SectionHeader(
                    title: 'Nossos Tratamentos Especializados',
                    subtitle:
                        'Descubra como nossas terapias podem ajudar você a alcançar seus '
                        'objetivos de saúde e bem-estar.',
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
                    scrollDirection: Axis.horizontal,
                    itemCount: services.length,
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpace.sm),
                    itemBuilder: (context, index) {
                      final s = services[index];
                      return ActionChip(
                        label: Text(s.title.split(' ').first),
                        onPressed: () => _scrollTo(s.id),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                for (var i = 0; i < services.length; i++)
                  _buildSection(services[i], i),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(Service service, int index) {
    return Column(
      children: [
        ServiceDetailSection(
          service: service,
          sectionKey: _sectionKeys[service.id]!,
          imageOnRight: index.isEven,
        ),
        if (index < 5) const Divider(height: 1, indent: AppSpace.lg, endIndent: AppSpace.lg),
      ],
    );
  }
}
