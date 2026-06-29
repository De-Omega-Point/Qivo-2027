import 'package:flutter/material.dart';

import '../../../core/theme/qivo_colours.dart';
import '../../../models/conversation_summary.dart';
import '../../shell/qivo_components.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({required this.summary, super.key});

  final ConversationSummary summary;

  @override
  Widget build(BuildContext context) {
    return QivoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: summary.title,
            subtitle: _dateLabel(summary.createdAt),
          ),
          const SizedBox(height: 16),
          _InfoBlock(label: 'Main topic', text: summary.mainTopic),
          _InfoBlock(label: 'What was decided', text: summary.decision),
          _InfoBlock(label: 'What is unresolved', text: summary.unresolved),
          _InfoBlock(
            label: 'Suggested next message',
            text: '"${summary.suggestedNextMessage}"',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Emotional load'),
              const SizedBox(width: 12),
              for (var i = 1; i <= 5; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.circle,
                    size: 12,
                    color: i <= summary.emotionalLoad
                        ? QivoColours.warningAmber
                        : QivoColours.border,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} at $hour:$minute';
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 5),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
