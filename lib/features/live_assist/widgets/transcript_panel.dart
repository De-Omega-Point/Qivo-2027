import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/qivo_providers.dart';
import '../../../core/theme/qivo_colours.dart';
import '../../../models/transcript_message.dart';
import '../../shell/qivo_components.dart';

class TranscriptPanel extends ConsumerWidget {
  const TranscriptPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transcript = ref.watch(liveAssistProvider).transcript;

    return QivoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Live transcript',
            subtitle: 'Speaker labels stay simple.',
          ),
          const SizedBox(height: 14),
          if (transcript.isEmpty)
            Text(
              'Start listening to see a simulated transcript.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            for (final message in transcript.take(8).toList().reversed)
              _TranscriptBubble(message: message),
        ],
      ),
    );
  }
}

class _TranscriptBubble extends StatelessWidget {
  const _TranscriptBubble({required this.message});

  final TranscriptMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.speaker == TranscriptSpeaker.you;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? QivoColours.primaryBlue.withOpacity(0.18)
              : QivoColours.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: QivoColours.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.speaker.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isUser ? QivoColours.aqua : QivoColours.mutedText,
                  ),
            ),
            const SizedBox(height: 5),
            Text(message.text, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
