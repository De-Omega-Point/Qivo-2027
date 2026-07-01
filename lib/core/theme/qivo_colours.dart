import 'package:flutter/material.dart';

class QivoColours {
  const QivoColours._();

  static const background = Color(0xFF07111F);
  static const surface = Color(0xFF0E1B2E);
  static const surfaceElevated = Color(0xFF13233A);
  static const primaryBlue = Color(0xFF2563EB);
  static const violet = Color(0xFF7C3AED);
  static const aqua = Color(0xFF22D3EE);
  static const liveGreen = Color(0xFF22C55E);
  static const warningAmber = Color(0xFFF59E0B);
  static const dangerRed = Color(0xFFEF4444);
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFFCBD5E1);
  static const mutedText = Color(0xFF64748B);
  static const border = Color(0x1AFFFFFF);
}

class QivoPalette extends ThemeExtension<QivoPalette> {
  const QivoPalette({
    required this.background,
    required this.backgroundEnd,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.mutedText,
    required this.border,
    required this.shadow,
  });

  final Color background;
  final Color backgroundEnd;
  final Color surface;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color mutedText;
  final Color border;
  final Color shadow;

  static const dark = QivoPalette(
    background: QivoColours.background,
    backgroundEnd: Color(0xFF0A1425),
    surface: QivoColours.surface,
    surfaceElevated: QivoColours.surfaceElevated,
    textPrimary: QivoColours.textPrimary,
    textSecondary: QivoColours.textSecondary,
    mutedText: QivoColours.mutedText,
    border: QivoColours.border,
    shadow: Color(0x59000000),
  );

  static const light = QivoPalette(
    background: Color(0xFFF6F8FB),
    backgroundEnd: Color(0xFFEFF6FF),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFEFF4FA),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    mutedText: Color(0xFF64748B),
    border: Color(0x1F0F172A),
    shadow: Color(0x1F0F172A),
  );

  @override
  QivoPalette copyWith({
    Color? background,
    Color? backgroundEnd,
    Color? surface,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? mutedText,
    Color? border,
    Color? shadow,
  }) {
    return QivoPalette(
      background: background ?? this.background,
      backgroundEnd: backgroundEnd ?? this.backgroundEnd,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      mutedText: mutedText ?? this.mutedText,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  QivoPalette lerp(ThemeExtension<QivoPalette>? other, double t) {
    if (other is! QivoPalette) return this;
    return QivoPalette(
      background: Color.lerp(background, other.background, t)!,
      backgroundEnd: Color.lerp(backgroundEnd, other.backgroundEnd, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension QivoThemePalette on BuildContext {
  QivoPalette get qivoPalette {
    return Theme.of(this).extension<QivoPalette>() ?? QivoPalette.dark;
  }
}
