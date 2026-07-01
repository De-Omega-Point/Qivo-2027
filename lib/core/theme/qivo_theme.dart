import 'package:flutter/material.dart';

import '../state/qivo_providers.dart';
import 'qivo_colours.dart';
import 'qivo_text_styles.dart';

class QivoTheme {
  const QivoTheme._();

  static ThemeData dark({required QivoSettings settings}) {
    return _theme(
      settings: settings,
      brightness: Brightness.dark,
      palette: QivoPalette.dark,
    );
  }

  static ThemeData light({required QivoSettings settings}) {
    return _theme(
      settings: settings,
      brightness: Brightness.light,
      palette: QivoPalette.light,
    );
  }

  static ThemeData _theme({
    required QivoSettings settings,
    required Brightness brightness,
    required QivoPalette palette,
  }) {
    final textTheme = QivoTextStyles.textTheme(
      largerText: settings.largerText,
      palette: palette,
    );
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: QivoColours.primaryBlue,
      brightness: brightness,
    ).copyWith(
      primary: QivoColours.primaryBlue,
      secondary: QivoColours.aqua,
      tertiary: QivoColours.violet,
      surface: palette.surface,
      error: QivoColours.dangerRed,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      extensions: [palette],
      colorScheme: colorScheme,
      textTheme: textTheme,
      dividerColor: palette.border,
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: settings.lowStimulusMode ? 0 : 12,
        shadowColor: palette.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: palette.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.border),
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
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: palette.border),
          foregroundColor: palette.textPrimary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.selected)
              ? QivoColours.aqua
              : palette.textSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.selected)
              ? QivoColours.aqua.withOpacity(0.24)
              : palette.surfaceElevated;
        }),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: QivoColours.primaryBlue.withOpacity(isDark ? 0.24 : 0.14),
        labelTextStyle: MaterialStatePropertyAll(textTheme.labelMedium),
      ),
    );
  }
}
