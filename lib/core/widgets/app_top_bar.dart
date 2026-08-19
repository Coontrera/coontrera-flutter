import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/auth_controller.dart';
import '../constants/app_assets.dart';
import '../router/route_paths.dart';
import 'app_svg_asset.dart';

/// Top bar shown on every institutional page (Home/Services/About/Contact),
/// always displaying the clinic logo, with a contextual "Entrar" action for
/// guests.
class AppTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authControllerProvider).valueOrNull != null;

    return AppBar(
      automaticallyImplyLeading: false,
      title: const AppSvgAsset(AppAssets.logo, height: 34),
      actions: [
        if (!isLoggedIn)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => context.push(RoutePaths.login),
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Entrar'),
            ),
          ),
      ],
    );
  }
}
