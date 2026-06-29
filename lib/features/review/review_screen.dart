import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/qivo_providers.dart';
import '../shell/qivo_components.dart';
import 'widgets/follow_up_tasks.dart';
import 'widgets/summary_card.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(summariesProvider);

    if (summaries.isEmpty) {
      return const Center(
        child: QivoCard(
          child: Text('No review is available yet. Start Live Assist first.'),
        ),
      );
    }

    final summary = summaries.first;

    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 880;
          if (compact) {
            return Column(
              children: [
                SummaryCard(summary: summary),
                const SizedBox(height: 16),
                FollowUpTasks(summary: summary),
                const SizedBox(height: 16),
                const PrivacyNotice(
                  text: 'You can save or delete this summary. Raw audio remains off by default.',
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: SummaryCard(summary: summary)),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    FollowUpTasks(summary: summary),
                    const SizedBox(height: 16),
                    const PrivacyNotice(
                      text: AppConstants.privacyDisclaimer,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
