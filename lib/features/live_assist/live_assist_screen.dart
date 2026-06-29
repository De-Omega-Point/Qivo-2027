import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/qivo_providers.dart';
import '../../core/theme/qivo_colours.dart';
import '../shell/qivo_components.dart';
import 'widgets/conversation_state_panel.dart';
import 'widgets/listening_panel.dart';
import 'widgets/quick_actions_panel.dart';
import 'widgets/suggestion_card.dart';
import 'widgets/transcript_panel.dart';

class LiveAssistScreen extends ConsumerWidget {
  const LiveAssistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveAssistProvider);
    final compact = MediaQuery.sizeOf(context).width < 960;

    final suggestions = QivoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'What to say next',
            subtitle: 'Only three suggestions at a time.',
          ),
          const SizedBox(height: 14),
          if (live.status == ListeningStatus.processing)
            const LinearProgressIndicator(minHeight: 3)
          else if (live.suggestions.isEmpty)
            Text(
              'Suggestions will appear after Qivo has enough conversation context.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            for (final suggestion in live.suggestions.take(3)) ...[
              SuggestionCard(suggestion: suggestion),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );

    final mainColumn = Column(
      children: [
        const ListeningPanel(),
        const SizedBox(height: 16),
        const TranscriptPanel(),
        if (live.status == ListeningStatus.finished) ...[
          const SizedBox(height: 16),
          QivoCard(
            child: Row(
              children: [
                const Icon(Icons.fact_check_rounded, color: QivoColours.aqua),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Ready to review what happened.'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(summariesProvider.notifier)
                        .saveFromLiveAssist(live.transcript);
                    ref.read(selectedNavProvider.notifier).state =
                        QivoNavItem.review;
                  },
                  child: const Text('Review'),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    final insightColumn = Column(
      children: [
        const ConversationStatePanel(),
        const SizedBox(height: 16),
        suggestions,
        const SizedBox(height: 16),
        const QuickActionsPanel(),
      ],
    );

    return SingleChildScrollView(
      child: compact
          ? Column(
              children: [
                mainColumn,
                const SizedBox(height: 16),
                insightColumn,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: mainColumn),
                const SizedBox(width: 16),
                Expanded(flex: 5, child: insightColumn),
              ],
            ),
    );
  }
}
