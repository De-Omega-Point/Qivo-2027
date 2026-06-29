import 'package:flutter/material.dart';

enum QivoNavItem {
  home('Home', Icons.home_rounded),
  liveAssist('Live Assist', Icons.graphic_eq_rounded),
  prep('Prep Coach', Icons.edit_note_rounded),
  review('Review', Icons.fact_check_rounded),
  history('History', Icons.history_rounded),
  analytics('Analytics', Icons.insights_rounded),
  settings('Settings', Icons.tune_rounded),
  admin('Admin', Icons.admin_panel_settings_rounded);

  const QivoNavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

class AppConstants {
  const AppConstants._();

  static const productName = 'Qivo';
  static const promise =
      'Qivo helps you understand the conversation and know what to say next.';
  static const privacyDisclaimer =
      'Qivo is a conversation support tool. It is not therapy, medical advice, or legal advice.';
}
