import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/qivo_providers.dart';
import '../../core/theme/qivo_colours.dart';
import 'qivo_components.dart';

class QivoTopBar extends ConsumerWidget {
  const QivoTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedNavProvider);
    final live = ref.watch(liveAssistProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: QivoColours.border)),
      ),
      child: Row(
        children: [
          const QivoLogo(size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              selected.label,
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          QivoStatusBadge(
            label: live.status.label,
            color: live.status == ListeningStatus.paused
                ? QivoColours.warningAmber
                : live.status == ListeningStatus.finished
                    ? QivoColours.mutedText
                    : QivoColours.liveGreen,
            icon: Icons.privacy_tip_outlined,
          ),
        ],
      ),
    );
  }
}
