import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/section_header.dart';
import '../widgets/photo_carousel.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const AppTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              title: 'Nossa História',
              subtitle: 'Conheça a trajetória e a paixão que movem a Clínica Coontrera.',
            ),
            const SizedBox(height: AppSpace.lg),
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 680;
              final foundersBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Dedicação e Profissionalismo', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: AppSpace.sm),
                  const Text(
                    'Nascemos de um sonho: começamos com fisioterapia e Mat Pilates, sempre '
                    'com cuidado e qualidade. À medida que a família de pacientes cresceu, '
                    'evoluímos junto — até nos tornarmos a clínica completa que somos hoje, '
                    'com a saúde de quem confia em nós sempre em primeiro lugar.',
                  ),
                ],
              );
              final foundersImage = ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Image.asset(AppAssets.founders, fit: BoxFit.cover),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: foundersBlock),
                    const SizedBox(width: AppSpace.lg),
                    Expanded(child: AspectRatio(aspectRatio: 4 / 3, child: foundersImage)),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(aspectRatio: 4 / 3, child: foundersImage),
                  const SizedBox(height: AppSpace.md),
                  foundersBlock,
                ],
              );
            }).animate().fadeIn(duration: 450.ms),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpace.xl),
              child: Divider(),
            ),
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 680;
              final evolutionBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Evolução e Excelência', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: AppSpace.sm),
                  const Text(
                    'Com mais de seis anos de trajetória, somos referência em fisioterapia, '
                    'pilates, hidroterapia e reabilitação na cidade — incluindo home care, '
                    'liberação miofascial, Dry Needling e quiropraxia clínica. Nossa equipe '
                    'especializada atende cada paciente, incluindo gestantes, com cuidado '
                    'personalizado.',
                  ),
                ],
              );
              final carousel = PhotoCarousel(assetPaths: AppAssets.aboutCarousel);

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: carousel),
                    const SizedBox(width: AppSpace.lg),
                    Expanded(child: evolutionBlock),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  evolutionBlock,
                  const SizedBox(height: AppSpace.md),
                  carousel,
                ],
              );
            }).animate().fadeIn(duration: 450.ms, delay: 100.ms),
            const SizedBox(height: AppSpace.xl),
          ],
        ),
      ),
    );
  }
}
