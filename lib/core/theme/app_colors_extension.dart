import 'package:flutter/material.dart';

/// Theme-aware semantic colors for the app, registered on [ThemeData] via
/// [ThemeData.extensions] so every screen can look up the right color for
/// the active brightness through `context.colors` instead of a fixed
/// constant. This is what makes light/dark mode actually work across
/// custom widgets (not just the handful of things Material themes by
/// default).
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.primary,
    required this.primaryHover,
    required this.onPrimary,
    required this.secondary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.background,
    required this.surface,
    required this.border,
    required this.success,
    required this.danger,
    required this.warning,
    required this.heroGradient,
    required this.cardShadow,
    required this.buttonShadow,
    required this.floatingShadow,
  });

  final Color primary;
  final Color primaryHover;

  /// Text/icon color for content placed on top of a [primary]-filled
  /// surface (e.g. a filled button label) — needs to stay readable even
  /// when [primary] itself flips from a dark to a light tone between
  /// themes.
  final Color onPrimary;
  final Color secondary;
  final Color accent;

  /// Main body/heading text color.
  final Color textPrimary;

  /// Secondary/muted text color.
  final Color textSecondary;

  /// Page/scaffold background.
  final Color background;

  /// Card/sheet/app-bar surface color.
  final Color surface;

  /// Divider / subtle fill / outline color.
  final Color border;

  final Color success;
  final Color danger;
  final Color warning;

  final List<Color> heroGradient;

  final List<BoxShadow> cardShadow;
  final List<BoxShadow> buttonShadow;
  final List<BoxShadow> floatingShadow;

  static const light = AppColorsExtension(
    primary: Color(0xFF7A4F9B),
    primaryHover: Color(0xFF613E7C),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFA076C2),
    accent: Color(0xFFC7A2E4),
    textPrimary: Color(0xFF311B40),
    textSecondary: Color(0xFF6D5A7C),
    background: Color(0xFFFBF9FF),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFF0E8F7),
    success: Color(0xFF28A745),
    danger: Color(0xFFDC3545),
    warning: Color(0xFFF0A83A),
    heroGradient: [Color(0xD97A4F9B), Color(0xF24A154B)],
    cardShadow: [
      BoxShadow(color: Color(0x1A7A4F9B), blurRadius: 16, offset: Offset(0, 6)),
    ],
    buttonShadow: [
      BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 4)),
    ],
    floatingShadow: [
      BoxShadow(color: Color(0x2E311B40), blurRadius: 24, offset: Offset(0, 10)),
    ],
  );

  static const dark = AppColorsExtension(
    primary: Color(0xFFB794D6),
    primaryHover: Color(0xFFCBAAE0),
    onPrimary: Color(0xFF1F1428),
    secondary: Color(0xFF8C63AC),
    accent: Color(0xFFC7A2E4),
    textPrimary: Color(0xFFF3EEFA),
    textSecondary: Color(0xFFB6A3C6),
    background: Color(0xFF15101B),
    surface: Color(0xFF211A2B),
    border: Color(0xFF382C46),
    success: Color(0xFF4CD97B),
    danger: Color(0xFFFF7A7A),
    warning: Color(0xFFFFC069),
    heroGradient: [Color(0xFF4A3361), Color(0xFF1C1424)],
    cardShadow: [
      BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 6)),
    ],
    buttonShadow: [
      BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 4)),
    ],
    floatingShadow: [
      BoxShadow(color: Color(0x80000000), blurRadius: 24, offset: Offset(0, 10)),
    ],
  );

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? primaryHover,
    Color? onPrimary,
    Color? secondary,
    Color? accent,
    Color? textPrimary,
    Color? textSecondary,
    Color? background,
    Color? surface,
    Color? border,
    Color? success,
    Color? danger,
    Color? warning,
    List<Color>? heroGradient,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? buttonShadow,
    List<BoxShadow>? floatingShadow,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      heroGradient: heroGradient ?? this.heroGradient,
      cardShadow: cardShadow ?? this.cardShadow,
      buttonShadow: buttonShadow ?? this.buttonShadow,
      floatingShadow: floatingShadow ?? this.floatingShadow,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      heroGradient: t < 0.5 ? heroGradient : other.heroGradient,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      buttonShadow: t < 0.5 ? buttonShadow : other.buttonShadow,
      floatingShadow: t < 0.5 ? floatingShadow : other.floatingShadow,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
}
