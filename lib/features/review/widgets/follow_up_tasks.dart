import 'package:flutter/material.dart';

import '../../../core/theme/qivo_colours.dart';
import '../../../models/conversation_summary.dart';
import '../../shell/qivo_components.dart';

class FollowUpTasks extends StatelessWidget {
  const FollowUpTasks({required this.summary, super.key});

  final ConversationSummary summary;

  @override
  Widget build(BuildContext context) {
    return QivoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Follow-up tasks'),
          const SizedBox(height: 14),
          for (final task in summary.followUps)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_box_outline_blank_rounded,
                    color: QivoColours.aqua,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(task)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_rounded),
                label: const Text('Save'),
                onPressed: () {},
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete'),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
