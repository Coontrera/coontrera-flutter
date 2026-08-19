import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_svg_asset.dart';

class AuthHeaderLogo extends StatelessWidget {
  const AuthHeaderLogo({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const AppSvgAsset(AppAssets.logo, width: 160)
            .animate()
            .fadeIn(duration: 450.ms)
            .slideY(begin: -0.1, end: 0, curve: Curves.easeOut),
        const SizedBox(height: 20),
        Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center)
            .animate()
            .fadeIn(delay: 100.ms, duration: 400.ms),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
      ],
    );
  }
}
