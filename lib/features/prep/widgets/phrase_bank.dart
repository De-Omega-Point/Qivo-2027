import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/qivo_providers.dart';
import '../../../core/theme/qivo_colours.dart';
import '../../shell/qivo_components.dart';

class PhraseBank extends ConsumerWidget {
  const PhraseBank({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final output = ref.watch(prepProvider);

    if (output == null) {
      return const QivoCard(
        child: Text(
          'Your conversation prep will appear here after you generate it.',
        ),
      );
    }

    final phrases = [
      ('Opening phrase', output.openingPhrase),
      ('Clarifying phrase', output.clarifyingPhrase),
      ('Boundary phrase', output.boundaryPhrase),
      ('Exit phrase', output.exitPhrase),
    ];

    return QivoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Conversation prep',
            subtitle: 'Short phrases to keep nearby.',
          ),
          const SizedBox(height: 16),
          for (final phrase in phrases) ...[
            _PhraseRow(label: phrase.$1, text: phrase.$2),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          Text('Three key points', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          for (final point in output.keyPoints)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: QivoColours.liveGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(point)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PhraseRow extends StatelessWidget {
  const _PhraseRow({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: QivoColours.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QivoColours.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text('"$text"', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
