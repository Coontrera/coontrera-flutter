import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';

class ContactActionCard extends StatelessWidget {
  const ContactActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.infoLine,
    required this.onTap,
    this.delay = Duration.zero,
  });

  final Widget icon;
  final String title;
  final String actionLabel;
  final String infoLine;
  final VoidCallback? onTap;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpace.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: colors.cardShadow,
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: icon,
              ),
              const SizedBox(height: AppSpace.md),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpace.xs),
              Text(
                actionLabel,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.primary),
              ),
              const SizedBox(height: AppSpace.xs),
              Text(
                infoLine,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay, duration: 400.ms).slideY(begin: 0.12, end: 0);
  }
}
