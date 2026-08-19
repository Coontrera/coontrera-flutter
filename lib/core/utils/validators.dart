abstract final class Validators {
  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _phoneDigitsRegex = RegExp(r'\D');

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu nome';
    if (v.length < 3) return 'Nome muito curto';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu e-mail';
    if (!_emailRegex.hasMatch(v)) return 'E-mail inválido';
    return null;
  }

  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu telefone';
    final digits = v.replaceAll(_phoneDigitsRegex, '');
    if (digits.length < 10 || digits.length > 11) {
      return 'Telefone inválido';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Informe sua senha';
    if (v.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() passwordGetter) {
    return (value) {
      final v = value ?? '';
      if (v.isEmpty) return 'Confirme sua senha';
      if (v != passwordGetter()) return 'As senhas não coincidem';
      return null;
    };
  }

  static String? required(String? value, {String message = 'Campo obrigatório'}) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  }
}
