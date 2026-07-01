import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'qivo_colours.dart';

class QivoTextStyles {
  const QivoTextStyles._();

  static TextTheme textTheme({
    required bool largerText,
    required QivoPalette palette,
  }) {
    final scale = largerText ? 1.1 : 1.0;
    final base = GoogleFonts.interTextTheme();

    TextStyle style(double size, FontWeight weight, Color color) {
      return GoogleFonts.inter(
        fontSize: size * scale,
        fontWeight: weight,
        color: color,
        letterSpacing: 0,
        height: 1.25,
      );
    }

    return base.copyWith(
      displaySmall: style(34, FontWeight.w800, palette.textPrimary),
      headlineMedium: style(28, FontWeight.w800, palette.textPrimary),
      titleLarge: style(22, FontWeight.w700, palette.textPrimary),
      titleMedium: style(17, FontWeight.w700, palette.textPrimary),
      bodyLarge: style(16, FontWeight.w500, palette.textPrimary),
      bodyMedium: style(14, FontWeight.w500, palette.textSecondary),
      bodySmall: style(12, FontWeight.w500, palette.mutedText),
      labelLarge: style(15, FontWeight.w700, palette.textPrimary),
      labelMedium: style(13, FontWeight.w700, palette.textSecondary),
    );
  }
}
