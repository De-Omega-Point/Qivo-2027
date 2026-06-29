import 'package:flutter/material.dart';

import '../../../core/theme/qivo_colours.dart';
import '../../../models/ai_suggestion.dart';

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({required this.suggestion, super.key});

  final AiSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QivoColours.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: QivoColours.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: QivoColours.aqua.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  suggestion.type.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: QivoColours.aqua,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${suggestion.phrase}"',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            suggestion.whyItHelps,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
