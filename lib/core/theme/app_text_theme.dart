import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors_extension.dart';

/// Typography mirroring the web app's Google Fonts pairing:
/// Playfair Display for headings (elegant serif), Poppins for body/UI.
abstract final class AppTextTheme {
  static TextTheme build(AppColorsExtension colors) {
    final base = GoogleFonts.poppinsTextTheme();
    final headings = GoogleFonts.playfairDisplayTextTheme();

    return base.copyWith(
      displayLarge: headings.displayLarge?.copyWith(
        color: colors.primary,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: headings.displayMedium?.copyWith(
        color: colors.primary,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: headings.displaySmall?.copyWith(
        color: colors.primary,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: headings.headlineLarge?.copyWith(
        color: colors.primary,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: headings.headlineMedium?.copyWith(
        color: colors.primary,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: headings.headlineSmall?.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: headings.titleLarge?.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: colors.textPrimary, height: 1.6),
      bodyMedium: base.bodyMedium?.copyWith(color: colors.textPrimary, height: 1.6),
      bodySmall: base.bodySmall?.copyWith(color: colors.textSecondary, height: 1.5),
      labelLarge: base.labelLarge?.copyWith(
        color: colors.onPrimary,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(color: colors.textSecondary),
      labelSmall: base.labelSmall?.copyWith(color: colors.textSecondary),
    );
  }
}
