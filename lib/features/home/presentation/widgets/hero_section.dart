import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.heroGradient,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Movimento é Vida.\nDescubra a Sua Melhor Versão.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15, end: 0),
          const SizedBox(height: AppSpace.md),
          Text(
            'Na Coontrera, combinamos a arte do Pilates e a ciência da Fisioterapia para '
            'oferecer a você uma jornada única de saúde, bem-estar e recuperação.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.white.withValues(alpha: 0.92)),
          ).animate().fadeIn(delay: 150.ms, duration: 500.ms).slideY(begin: 0.15, end: 0),
          const SizedBox(height: AppSpace.lg),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colors.primary,
            ),
            onPressed: () => context.go(RoutePaths.services),
            child: const Text('Conheça Nossos Tratamentos'),
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms).scale(
                begin: const Offset(0.9, 0.9),
                curve: Curves.easeOutBack,
              ),
        ],
      ),
    );
  }
}
