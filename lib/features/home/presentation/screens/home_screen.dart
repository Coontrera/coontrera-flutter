import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../widgets/cta_banner.dart';
import '../widgets/hero_section.dart';
import '../widgets/service_highlight_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HeroSection(),
            Padding(
              padding: const EdgeInsets.all(AppSpace.lg),
              child: Column(
                children: [
                  Text(
                    'Serviços Pensados para Você',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    'Oferecemos uma gama completa de terapias para atender suas necessidades '
                    'individuais, desde a reabilitação até a busca por uma vida mais ativa e '
                    'equilibrada.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpace.lg),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 600;
                      final cards = const [
                        ServiceHighlightCard(
                          icon: Icons.self_improvement,
                          title: 'Pilates Terapêutico',
                          description:
                              'Fortaleça seu corpo, melhore a postura e alivie dores com o '
                              'método Pilates adaptado às suas necessidades.',
                        ),
                        ServiceHighlightCard(
                          icon: Icons.directions_run,
                          title: 'Fisioterapia Especializada',
                          description:
                              'Recupere-se de lesões e cirurgias com tratamentos '
                              'fisioterapêuticos avançados e personalizados.',
                          delay: Duration(milliseconds: 80),
                        ),
                        ServiceHighlightCard(
                          icon: Icons.accessibility_new,
                          title: 'Quiropraxia Clínica',
                          description:
                              'Alinhe sua coluna, alivie tensões e promova o bem-estar geral '
                              'através de ajustes quiropráticos precisos.',
                          delay: Duration(milliseconds: 160),
                        ),
                        ServiceHighlightCard(
                          icon: Icons.water_drop_outlined,
                          title: 'Hidroterapia',
                          description:
                              'Reabilitação suave e eficaz na água, ideal para todas as idades '
                              'e condições físicas.',
                          delay: Duration(milliseconds: 240),
                        ),
                      ];
                      return GridView.count(
                        crossAxisCount: isWide ? 2 : 1,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSpace.md,
                        crossAxisSpacing: AppSpace.md,
                        childAspectRatio: isWide ? 1.5 : 1.7,
                        children: cards,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpace.lg),
                  OutlinedButton(
                    onPressed: () => context.go(RoutePaths.services),
                    child: const Text('Ver Todos os Serviços'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpace.xxl),
              child: CtaBanner(),
            ),
          ],
        ),
      ),
    );
  }
}
