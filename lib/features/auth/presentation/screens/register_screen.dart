import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/repositories/repository_exceptions.dart';
import '../../application/auth_controller.dart';
import '../widgets/auth_header_logo.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _acceptedTerms = false;
  String? _formError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _formError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptedTerms) {
      setState(() => _formError = 'Você precisa aceitar os termos para continuar.');
      return;
    }
    FocusScope.of(context).unfocus();

    await ref.read(authControllerProvider.notifier).register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
        );

    final state = ref.read(authControllerProvider);
    if (state.hasError && mounted) {
      final error = state.error;
      setState(() {
        _formError = error is AuthException ? error.message : 'Não foi possível cadastrar.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
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
                      const AuthHeaderLogo(
                        title: 'Crie sua conta',
                        subtitle: 'Agende suas sessões em poucos passos',
                      ),
                      const SizedBox(height: AppSpace.lg),
                      AuthTextField(
                        controller: _nameController,
                        label: 'Nome completo',
                        prefixIcon: Icons.person_outline,
                        validator: Validators.name,
                        autofillHints: const [AutofillHints.name],
                      ),
                      const SizedBox(height: AppSpace.md),
                      AuthTextField(
                        controller: _phoneController,
                        label: 'Telefone',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: Validators.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                      ),
                      const SizedBox(height: AppSpace.md),
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
                      ),
                      const SizedBox(height: AppSpace.md),
                      AuthTextField(
                        controller: _confirmController,
                        label: 'Confirme sua senha',
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        textInputAction: TextInputAction.done,
                        validator: Validators.confirmPassword(() => _passwordController.text),
                      ),
                      const SizedBox(height: AppSpace.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                          ),
                          const Expanded(
                            child: Text(
                              'Li e aceito os termos de uso e a política de privacidade.',
                            ),
                          ),
                        ],
                      ),
                      if (_formError != null) ...[
                        const SizedBox(height: AppSpace.xs),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _formError!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: colors.danger),
                          ),
                        ),
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
                              : const Text('Cadastrar'),
                        ),
                      ),
                      const SizedBox(height: AppSpace.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Já tem uma conta?'),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: const Text('Entrar'),
                          ),
                        ],
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
