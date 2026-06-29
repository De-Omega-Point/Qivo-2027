import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/qivo_providers.dart';
import '../../../core/theme/qivo_colours.dart';
import '../../../core/utils/responsive.dart';
import '../../shell/qivo_components.dart';

class QuickActionsPanel extends ConsumerWidget {
  const QuickActionsPanel({super.key});

  static const actions = [
    ('Pause phrase', Icons.pause_circle_outline_rounded),
    ('Clarify', Icons.help_outline_rounded),
    ('Slow down', Icons.speed_rounded),
    ('Summarise so far', Icons.notes_rounded),
    ('Save moment', Icons.bookmark_border_rounded),
    ('End conversation', Icons.stop_circle_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);

    return QivoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick actions'),
          const SizedBox(height: 14),
          if (isMobile)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.7,
              children: [
                for (final action in actions)
                  OutlinedButton.icon(
                    icon: Icon(action.$2, size: 18),
                    label: Text(
                      action.$1 == 'End conversation' ? 'End' : action.$1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: action.$1 == 'End conversation'
                          ? QivoColours.warningAmber
                          : QivoColours.textPrimary,
                    ),
                    onPressed: () => ref
                        .read(liveAssistProvider.notifier)
                        .quickAction(action.$1),
                  ),
              ],
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final action in actions)
                  OutlinedButton.icon(
                    icon: Icon(action.$2, size: 18),
                    label: Text(action.$1),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: action.$1 == 'End conversation'
                          ? QivoColours.warningAmber
                          : QivoColours.textPrimary,
                    ),
                    onPressed: () => ref
                        .read(liveAssistProvider.notifier)
                        .quickAction(action.$1),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
