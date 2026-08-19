import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors_extension.dart';
import '../theme/app_spacing.dart';

/// Page/section title + optional subtitle, matching the web app's
/// `.page-title` / `.lead` header pattern, with a gentle fade-up entrance.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.alignment = CrossAxisAlignment.center,
    this.textAlign = TextAlign.center,
    this.titleColor,
  });

  final String title;
  final String? subtitle;
  final CrossAxisAlignment alignment;
  final TextAlign textAlign;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          title,
          textAlign: textAlign,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: titleColor ?? colors.primary,
          ),
        ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.15, end: 0),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpace.sm),
          Text(
            subtitle!,
            textAlign: textAlign,
            style: theme.textTheme.bodyLarge?.copyWith(color: colors.textSecondary),
          ).animate().fadeIn(duration: 420.ms, delay: 100.ms).slideY(begin: 0.15, end: 0),
        ],
      ],
    );
  }
}
