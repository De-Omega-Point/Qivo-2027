import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/qivo_providers.dart';
import '../../core/theme/qivo_colours.dart';
import '../../core/utils/responsive.dart';
import '../shell/qivo_components.dart';
import 'widgets/conversation_state_panel.dart';
import 'widgets/listening_panel.dart';
import 'widgets/local_first_backend_panel.dart';
import 'widgets/need_now_strip.dart';
import 'widgets/suggestion_card.dart';
import 'widgets/transcript_panel.dart';

class LiveAssistScreen extends ConsumerWidget {
  const LiveAssistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveAssistProvider);
    final isMobile = Responsive.isMobile(context);
    final compact = MediaQuery.sizeOf(context).width < 960;

    final suggestions = QivoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'What to say next',
            subtitle: 'Fast, short, high-confidence options.',
          ),
          const SizedBox(height: 14),
          if (live.status == ListeningStatus.processing) ...[
            const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: 12),
          ],
          if (live.suggestions.isEmpty)
            Text(
              live.status == ListeningStatus.processing
                  ? 'Preparing useful options...'
                  : 'Suggestions will appear after Qivo has enough conversation context.',
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

    final reviewCta = live.status == ListeningStatus.finished
        ? _ReviewReadyCard(
            isMobile: isMobile,
            onReview: () => _saveAndReview(ref, live),
          )
        : const SizedBox.shrink();

    final mainColumn = Column(
      children: [
        const ListeningPanel(),
        const SizedBox(height: 16),
        const LocalFirstBackendPanel(),
        const SizedBox(height: 16),
        const NeedNowStrip(),
        const SizedBox(height: 16),
        const TranscriptPanel(),
        reviewCta,
      ],
    );

    final insightColumn = Column(
      children: [
        const ConversationStatePanel(),
        const SizedBox(height: 16),
        suggestions,
      ],
    );

    return SingleChildScrollView(
      child: compact
          ? Column(
              children: [
                const ListeningPanel(),
                const SizedBox(height: 16),
                const LocalFirstBackendPanel(),
                const SizedBox(height: 16),
                const NeedNowStrip(),
                const SizedBox(height: 16),
                suggestions,
                const SizedBox(height: 16),
                const TranscriptPanel(),
                const SizedBox(height: 16),
                const ConversationStatePanel(),
                reviewCta,
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

  void _saveAndReview(WidgetRef ref, LiveAssistState live) {
    ref.read(summariesProvider.notifier).saveFromLiveAssist(live.transcript);
    ref.read(selectedNavProvider.notifier).state = QivoNavItem.review;
  }
}

class _ReviewReadyCard extends StatelessWidget {
  const _ReviewReadyCard({
    required this.isMobile,
    required this.onReview,
  });

  final bool isMobile;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        const Icon(Icons.fact_check_rounded, color: QivoColours.aqua),
        const SizedBox(width: 12),
        const Expanded(child: Text('Ready to review what happened.')),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: QivoCard(
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  content,
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onReview,
                    child: const Text('Review'),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(child: content),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onReview,
                    child: const Text('Review'),
                  ),
                ],
              ),
      ),
    );
  }
}
