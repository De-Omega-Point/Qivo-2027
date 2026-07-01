import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/qivo_providers.dart';
import '../../../models/conversation_state.dart';
import '../../shell/qivo_components.dart';

class ConversationStatePanel extends ConsumerWidget {
  const ConversationStatePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(liveAssistProvider).conversationState;

    return QivoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Conversation pressure',
            subtitle: 'A gentle read of pace, clarity, and intensity.',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final state in ConversationState.values)
                QivoStatusBadge(
                  label: state.label,
                  color: state == current ? state.color : state.color.withOpacity(0.65),
                  icon: state == current
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
