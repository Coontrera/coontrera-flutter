import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../application/auth_controller.dart';
import '../widgets/auth_header_logo.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showDemoAccounts = false;
  int _shakeSeed = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref
        .read(authControllerProvider.notifier)
        .login(_emailController.text, _passwordController.text);
    final state = ref.read(authControllerProvider);
    if (state.hasError && mounted) {
      setState(() => _shakeSeed++);
    }
  }

  void _fillDemo(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpace.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(AppSpace.xl),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: colors.cardShadow,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AuthHeaderLogo(
                        title: 'Bem-vindo(a) de volta',
                        subtitle: widget.redirectTo != null
                            ? 'Faça login para continuar seu agendamento'
                            : 'Entre para gerenciar seus agendamentos',
                      ),
                      const SizedBox(height: AppSpace.lg),
                      AuthTextField(
                        controller: _emailController,
                        label: 'E-mail',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline,
                        validator: Validators.email,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: AppSpace.md),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Senha',
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        validator: Validators.password,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                      ),
                      if (authState.hasError) ...[
                        const SizedBox(height: AppSpace.md),
                        Container(
                          key: ValueKey(_shakeSeed),
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpace.sm),
                          decoration: BoxDecoration(
                            color: colors.danger.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: colors.danger, size: 20),
                              const SizedBox(width: AppSpace.sm),
                              Expanded(
                                child: Text(
                                  'E-mail ou senha inválidos.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: colors.danger),
                                ),
                              ),
                            ],
                          ),
                        ).animate().shake(duration: 400.ms, hz: 4),
                      ],
                      const SizedBox(height: AppSpace.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation(colors.onPrimary),
                                  ),
                                )
                              : const Text('Entrar'),
                        ),
                      ),
                      const SizedBox(height: AppSpace.md),
                      TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: const Text('Esqueceu a senha?'),
                      ),
                      const Divider(height: AppSpace.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Não tem uma conta?'),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            child: const Text('Cadastre-se'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpace.sm),
                      _DemoAccountsPanel(
                        expanded: _showDemoAccounts,
                        onToggle: () => setState(() => _showDemoAccounts = !_showDemoAccounts),
                        onSelect: _fillDemo,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoAccountsPanel extends StatelessWidget {
  const _DemoAccountsPanel({
    required this.expanded,
    required this.onToggle,
    required this.onSelect,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final void Function(String email, String password) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.sm),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: colors.textSecondary),
                  const SizedBox(width: AppSpace.xs),
                  Expanded(
                    child: Text(
                      'Contas de demonstração',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.sm, 0, AppSpace.sm, AppSpace.sm),
              child: Column(
                children: [
                  _DemoAccountTile(
                    label: 'Administrador',
                    email: 'admin@coontrera.com',
                    password: 'Admin@123',
                    onTap: () => onSelect('admin@coontrera.com', 'Admin@123'),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  _DemoAccountTile(
                    label: 'Cliente',
                    email: 'cliente@coontrera.com',
                    password: 'Cliente@123',
                    onTap: () => onSelect('cliente@coontrera.com', 'Cliente@123'),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 250.ms),
        ],
      ),
    );
  }
}

class _DemoAccountTile extends StatelessWidget {
  const _DemoAccountTile({
    required this.label,
    required this.email,
    required this.password,
    required this.onTap,
  });

  final String label;
  final String email;
  final String password;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: AppSpace.xs),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                  Text(
                    '$email · $password',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.touch_app_outlined, size: 16, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
