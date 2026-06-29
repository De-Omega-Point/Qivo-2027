import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/qivo_providers.dart';
import '../../core/theme/qivo_colours.dart';
import '../shell/qivo_components.dart';
import 'widgets/low_stimulus_toggle.dart';
import 'widgets/privacy_controls.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 860;
          final themeCard = QivoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Theme mode'),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'Dark',
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode_rounded),
                    ),
                    ButtonSegment(
                      value: 'Light later',
                      label: Text('Light later'),
                      icon: Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: 'System later',
                      label: Text('System later'),
                      icon: Icon(Icons.devices_rounded),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (selection) => ref
                      .read(settingsProvider.notifier)
                      .updateThemeMode(selection.first),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dark is active for the MVP. Other modes are shown for the planned settings model.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: QivoColours.textSecondary,
                      ),
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              children: [
                const LowStimulusToggle(),
                const SizedBox(height: 16),
                const PrivacyControls(),
                const SizedBox(height: 16),
                themeCard,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: LowStimulusToggle()),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    const PrivacyControls(),
                    const SizedBox(height: 16),
                    themeCard,
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
