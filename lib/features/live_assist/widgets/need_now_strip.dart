import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/qivo_providers.dart';
import '../../../core/theme/qivo_colours.dart';
import '../../../core/utils/responsive.dart';
import '../../shell/qivo_components.dart';

class NeedNowStrip extends ConsumerWidget {
  const NeedNowStrip({super.key});

  static const needs = [
    ('Clarify', Icons.help_outline_rounded),
    ('Slow down', Icons.speed_rounded),
    ('Set boundary', Icons.back_hand_outlined),
    ('Summarise', Icons.notes_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);

    return QivoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'What do you need right now?',
            subtitle: 'Choose one direction. Qivo will keep suggestions short.',
          ),
          const SizedBox(height: 14),
          if (isMobile)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.65,
              children: [
                for (final need in needs)
                  _NeedButton(label: need.$1, icon: need.$2),
              ],
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final need in needs)
                  _NeedButton(label: need.$1, icon: need.$2),
              ],
            ),
        ],
      ),
    );
  }
}

class _NeedButton extends ConsumerWidget {
  const _NeedButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: QivoColours.textPrimary,
        side: BorderSide(color: QivoColours.aqua.withOpacity(0.42)),
        backgroundColor: QivoColours.aqua.withOpacity(0.06),
      ),
      onPressed: () {
        final action = switch (label) {
          'Set boundary' => 'Pause phrase',
          'Summarise' => 'Summarise so far',
          _ => label,
        };
        ref.read(liveAssistProvider.notifier).quickAction(action);
      },
    );
  }
}
