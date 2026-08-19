import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/widgets/empty_state.dart';

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acesso restrito')),
      body: EmptyState(
        icon: Icons.lock_outline,
        title: 'Você não tem permissão para acessar esta área',
        message: 'Esta seção é exclusiva para administradores da clínica.',
        actionLabel: 'Voltar ao início',
        onAction: () => context.go(RoutePaths.home),
      ),
    );
  }
}
