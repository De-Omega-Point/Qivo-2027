import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/qivo_providers.dart';
import '../../shell/qivo_components.dart';

class LowStimulusToggle extends ConsumerWidget {
  const LowStimulusToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return QivoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Comfort controls',
            subtitle: 'Reduce motion and visual intensity.',
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Low-stimulus mode'),
            subtitle: const Text('Flatter cards, fewer gradients, calmer motion.'),
            value: settings.lowStimulusMode,
            onChanged: controller.updateLowStimulus,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Larger text'),
            value: settings.largerText,
            onChanged: controller.updateLargerText,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reduce animations'),
            value: settings.reduceAnimations,
            onChanged: controller.updateReduceAnimations,
          ),
        ],
      ),
    );
  }
}
