import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/contact_constants.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/launch_helpers.dart';
import '../../../../core/widgets/app_svg_asset.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../../data/models/user_role.dart';

class CtaBanner extends ConsumerWidget {
  const CtaBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final isClient = user != null && user.role == UserRole.client;
    final colors = context.colors;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
      padding: const EdgeInsets.all(AppSpace.xl),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Text(
            'Pronto para Transformar sua Saúde?',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: colors.onPrimary),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            'Agende sua aula experimental gratuita ou uma avaliação e dê o primeiro passo '
            'rumo a uma vida com mais qualidade e menos dor.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colors.onPrimary.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: AppSpace.lg),
          if (isClient)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.onPrimary,
                foregroundColor: colors.primary,
              ),
              onPressed: () => context.push(RoutePaths.book),
              icon: const Icon(Icons.event_available_outlined),
              label: const Text('Agendar no App'),
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.onPrimary,
                foregroundColor: colors.primary,
              ),
              onPressed: () => LaunchHelpers.openUrl(ContactConstants.whatsappUrl()),
              icon: const AppSvgAsset(AppAssets.whatsapp, width: 20, height: 20),
              label: const Text('Agendar via WhatsApp'),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1, end: 0);
  }
}
