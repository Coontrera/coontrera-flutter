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
import '../../../../core/widgets/expandable_text.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../data/models/service.dart';
import '../../../../data/models/user_role.dart';
import '../../../auth/application/auth_controller.dart';

class ServiceDetailSection extends ConsumerWidget {
  const ServiceDetailSection({
    super.key,
    required this.service,
    required this.sectionKey,
    required this.imageOnRight,
  });

  final Service service;
  final GlobalKey sectionKey;
  final bool imageOnRight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final isClient = user != null && user.role == UserRole.client;
    final theme = Theme.of(context);
    final colors = context.colors;

    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(service.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpace.sm),
        ExpandableText(
          service.description,
          style: theme.textTheme.bodyMedium,
          collapsedMaxLines: 3,
        ),
        const SizedBox(height: AppSpace.md),
        ...service.benefits.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: colors.primary, size: 18),
                const SizedBox(width: AppSpace.xs),
                Expanded(child: Text(b, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        if (isClient)
          ElevatedButton.icon(
            onPressed: () => context.push(RoutePaths.book, extra: service.id),
            icon: const Icon(Icons.event_available_outlined),
            label: Text(service.ctaText),
          )
        else
          ElevatedButton.icon(
            onPressed: () => LaunchHelpers.openUrl(
              ContactConstants.whatsappUrl('Olá, gostaria de saber mais sobre ${service.title}.'),
            ),
            icon: const AppSvgAsset(AppAssets.whatsapp, width: 18, height: 18),
            label: Text(service.ctaText),
          ),
      ],
    );

    final imageContent = Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: colors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: AppSvgAsset(service.iconAsset, height: 160),
    );

    return Container(
      key: sectionKey,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.xl),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 680) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: imageOnRight
                  ? [
                      Expanded(flex: 6, child: textContent),
                      const SizedBox(width: AppSpace.lg),
                      Expanded(flex: 5, child: imageContent),
                    ]
                  : [
                      Expanded(flex: 5, child: imageContent),
                      const SizedBox(width: AppSpace.lg),
                      Expanded(flex: 6, child: textContent),
                    ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 180, child: imageContent),
              const SizedBox(height: AppSpace.md),
              textContent,
            ],
          );
        },
      ),
    ).animate().fadeIn(duration: 450.ms).slideX(
          begin: imageOnRight ? -0.05 : 0.05,
          end: 0,
        );
  }
}
