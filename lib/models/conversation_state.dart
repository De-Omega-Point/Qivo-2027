import 'package:flutter/material.dart';

import '../core/theme/qivo_colours.dart';

enum ConversationState {
  calm('Calm', QivoColours.liveGreen),
  fast('Fast', QivoColours.warningAmber),
  unclear('Unclear', QivoColours.aqua),
  tense('Tense', QivoColours.dangerRed),
  emotionallyLoaded('Emotionally loaded', QivoColours.violet);

  const ConversationState(this.label, this.color);
  final String label;
  final Color color;
}
