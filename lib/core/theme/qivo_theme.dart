import 'package:flutter/material.dart';

import '../state/qivo_providers.dart';
import 'qivo_colours.dart';
import 'qivo_text_styles.dart';

class QivoTheme {
  const QivoTheme._();

  static ThemeData dark({required QivoSettings settings}) {
    final textTheme = QivoTextStyles.textTheme(largerText: settings.largerText);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: QivoColours.background,
      colorScheme: const ColorScheme.dark(
        primary: QivoColours.primaryBlue,
        secondary: QivoColours.aqua,
        tertiary: QivoColours.violet,
        surface: QivoColours.surface,
        error: QivoColours.dangerRed,
      ),
      textTheme: textTheme,
      dividerColor: QivoColours.border,
      cardTheme: CardTheme(
        color: QivoColours.surface,
        elevation: settings.lowStimulusMode ? 0 : 12,
        shadowColor: Colors.black.withOpacity(0.28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: QivoColours.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: QivoColours.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: QivoColours.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: QivoColours.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: QivoColours.aqua, width: 1.3),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: QivoColours.primaryBlue,
          foregroundColor: QivoColours.textPrimary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: QivoColours.border),
          foregroundColor: QivoColours.textPrimary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.selected)
              ? QivoColours.aqua
              : QivoColours.textSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.selected)
              ? QivoColours.aqua.withOpacity(0.24)
              : QivoColours.surfaceElevated;
        }),
      ),
    );
  }
}
