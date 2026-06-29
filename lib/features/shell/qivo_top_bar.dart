import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/qivo_providers.dart';
import '../../core/theme/qivo_colours.dart';
import '../../core/utils/responsive.dart';
import 'qivo_components.dart';

class QivoTopBar extends ConsumerWidget {
  const QivoTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedNavProvider);
    final live = ref.watch(liveAssistProvider);
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 22,
        vertical: isMobile ? 10 : 16,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: QivoColours.border)),
      ),
      child: Row(
        children: [
          QivoLogo(size: isMobile ? 30 : 34),
          SizedBox(width: isMobile ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMobile ? 'Qivo' : selected.label,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isMobile)
                  Text(
                    selected.label,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          QivoStatusBadge(
            label: isMobile ? _compactStatus(live.status) : live.status.label,
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

  String _compactStatus(ListeningStatus status) {
    return switch (status) {
      ListeningStatus.listening => 'Live',
      ListeningStatus.processing => 'Thinking',
      ListeningStatus.suggesting => 'Ready',
      ListeningStatus.paused => 'Paused',
      ListeningStatus.finished => 'Done',
      ListeningStatus.idle => 'Private',
    };
  }
}
