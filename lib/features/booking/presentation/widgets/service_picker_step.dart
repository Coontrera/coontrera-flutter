import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_svg_asset.dart';
import '../../../../data/models/service.dart';

class ServicePickerStep extends StatelessWidget {
  const ServicePickerStep({
    super.key,
    required this.services,
    required this.selectedServiceId,
    required this.onSelect,
  });

  final List<Service> services;
  final String? selectedServiceId;
  final void Function(Service) onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpace.lg),
      itemCount: services.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpace.sm),
      itemBuilder: (context, index) {
        final service = services[index];
        final isSelected = service.id == selectedServiceId;
        return _ServiceTile(
          service: service,
          isSelected: isSelected,
          onTap: () => onSelect(service),
        ).animate().fadeIn(delay: (30 * index).ms, duration: 300.ms).slideX(begin: 0.05, end: 0);
      },
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.isSelected, required this.onTap});

  final Service service;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedScale(
      scale: isSelected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 180),
      child: Material(
        color: isSelected ? colors.accent.withValues(alpha: 0.2) : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpace.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected ? colors.primary : colors.border,
                width: isSelected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.border.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: AppSvgAsset(service.iconAsset),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(service.title, style: Theme.of(context).textTheme.titleMedium),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.chevron_right,
                  color: isSelected ? colors.primary : colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
