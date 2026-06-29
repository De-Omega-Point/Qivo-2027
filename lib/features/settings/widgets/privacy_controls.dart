import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/state/qivo_providers.dart';
import '../../../core/theme/qivo_colours.dart';
import '../../shell/qivo_components.dart';

class PrivacyControls extends ConsumerWidget {
  const PrivacyControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return QivoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Privacy and data',
            subtitle: 'Raw audio saving is off by default.',
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Save raw audio'),
            subtitle: const Text('Default off. No audio is saved in this prototype.'),
            value: settings.saveRawAudio,
            onChanged: controller.updateRawAudio,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Save transcript'),
            value: settings.saveTranscript,
            onChanged: controller.updateSaveTranscript,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Save summaries'),
            value: settings.saveSummaries,
            onChanged: controller.updateSaveSummaries,
          ),
          const SizedBox(height: 12),
          const PrivacyNotice(text: AppConstants.privacyDisclaimer),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.download_rounded),
                label: const Text('Data export'),
                onPressed: () {},
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('Delete all data'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: QivoColours.dangerRed,
                ),
                onPressed: () => ref.read(summariesProvider.notifier).clear(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
