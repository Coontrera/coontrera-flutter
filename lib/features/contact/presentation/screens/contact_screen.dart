import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/contact_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/launch_helpers.dart';
import '../../../../core/widgets/app_svg_asset.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/section_header.dart';
import '../widgets/contact_action_card.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              title: 'Entre em Contato',
              subtitle: 'Estamos prontos para ouvir você e ajudar no que for preciso.',
            ),
            const SizedBox(height: AppSpace.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 620;
                final cards = [
                  ContactActionCard(
                    icon: const AppSvgAsset(AppAssets.whatsapp, width: 26, height: 26),
                    title: 'WhatsApp',
                    actionLabel: 'Clique aqui para agendar ou tirar dúvidas',
                    infoLine: ContactConstants.whatsappDisplay,
                    onTap: () => LaunchHelpers.openUrl(ContactConstants.whatsappUrl()),
                  ),
                  ContactActionCard(
                    icon: const AppSvgAsset(AppAssets.insta, width: 26, height: 26),
                    title: 'Instagram',
                    actionLabel: 'Siga-nos no Instagram',
                    infoLine: ContactConstants.instagramHandle,
                    onTap: () => LaunchHelpers.openUrl(ContactConstants.instagramUrl),
                    delay: const Duration(milliseconds: 100),
                  ),
                  ContactActionCard(
                    icon: const AppSvgAsset(AppAssets.map, width: 26, height: 26),
                    title: 'Nossa Localização',
                    actionLabel: ContactConstants.cityLine,
                    infoLine: ContactConstants.zipCode,
                    onTap: () => LaunchHelpers.openUrl(ContactConstants.mapsUrl),
                    delay: const Duration(milliseconds: 200),
                  ),
                ];

                if (isWide) {
                  return Row(
                    children: cards
                        .map((c) => Expanded(child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
                              child: c,
                            )))
                        .toList(),
                  );
                }
                return Column(
                  children: cards
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpace.md),
                            child: c,
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: AppSpace.xl),
            Text(
              'Mapa de Localização',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              ContactConstants.addressLine,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpace.md),
            OutlinedButton.icon(
              onPressed: () => LaunchHelpers.openUrl(ContactConstants.mapsUrl),
              icon: const Icon(Icons.map_outlined),
              label: const Text('Abrir no Google Maps'),
            ),
            const SizedBox(height: AppSpace.xl),
          ],
        ),
      ),
    );
  }
}
