import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/qivo_providers.dart';
import '../../core/theme/qivo_colours.dart';
import '../../services/ai_backend_config.dart';
import '../shell/qivo_components.dart';
import 'widgets/low_stimulus_toggle.dart';
import 'widgets/privacy_controls.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final backend = ref.watch(aiBackendConfigProvider);

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
                      value: 'Light',
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: 'System',
                      label: Text('System'),
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
                  'Theme changes apply across the app immediately.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.qivoPalette.textSecondary,
                      ),
                ),
              ],
            ),
          );
          final backendCard = QivoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'AI backend',
                  subtitle: backend.connectionLabel,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    QivoStatusBadge(
                      label: backend.providerName,
                      color: QivoColours.aqua,
                      icon: Icons.bolt_rounded,
                    ),
                    QivoStatusBadge(
                      label: backend.model,
                      color: QivoColours.violet,
                      icon: Icons.auto_awesome_rounded,
                    ),
                    if (backend.isLocalOverride)
                      const QivoStatusBadge(
                        label: 'Local test',
                        color: QivoColours.warningAmber,
                        icon: Icons.computer_rounded,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _backendMessage(backend),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.qivoPalette.textSecondary,
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
                backendCard,
                const SizedBox(height: 16),
                const _LocalBackendControls(),
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
                    backendCard,
                    const SizedBox(height: 16),
                    const _LocalBackendControls(),
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

  String _backendMessage(AiBackendConfig backend) {
    if (backend.isLocalOverride) {
      return 'Local-first mode is active. Qivo will call your local proxy and fall back to mock suggestions if the request fails.';
    }

    if (backend.isConfigured) {
      return 'Live suggestions use the configured backend proxy. The mock service remains as a fallback if the request fails.';
    }

    return 'Free-start mode is selected. Enable Local-first backend below to test the Groq proxy on this device.';
  }
}

class _LocalBackendControls extends ConsumerStatefulWidget {
  const _LocalBackendControls();

  @override
  ConsumerState<_LocalBackendControls> createState() =>
      _LocalBackendControlsState();
}

class _LocalBackendControlsState extends ConsumerState<_LocalBackendControls> {
  late final TextEditingController _proxyUrl;
  late final TextEditingController _aiModel;
  late final TextEditingController _sttModel;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _proxyUrl = TextEditingController(text: settings.localAiProxyUrl);
    _aiModel = TextEditingController(text: settings.localAiModel);
    _sttModel = TextEditingController(text: settings.localSttModel);
  }

  @override
  void dispose() {
    _proxyUrl.dispose();
    _aiModel.dispose();
    _sttModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return QivoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Local-first backend',
            subtitle: 'Use your Mac proxy before deploying anything.',
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Use local AI proxy'),
            subtitle: Text(
              settings.localAiEnabled
                  ? 'Live Assist will call this device first.'
                  : 'Qivo stays in mock mode until this is enabled.',
            ),
            value: settings.localAiEnabled,
            activeColor: QivoColours.aqua,
            onChanged: controller.updateLocalAiEnabled,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _proxyUrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Local proxy URL',
              prefixIcon: Icon(Icons.link_rounded),
            ),
            onChanged: controller.updateLocalAiProxyUrl,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _aiModel,
            decoration: const InputDecoration(
              labelText: 'AI model',
              prefixIcon: Icon(Icons.auto_awesome_rounded),
            ),
            onChanged: controller.updateLocalAiModel,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sttModel,
            decoration: const InputDecoration(
              labelText: 'Speech model',
              prefixIcon: Icon(Icons.graphic_eq_rounded),
            ),
            onChanged: controller.updateLocalSttModel,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.computer_rounded),
                label: const Text('Use localhost'),
                onPressed: () {
                  _proxyUrl.text = 'http://localhost:8787';
                  controller.updateLocalAiProxyUrl(_proxyUrl.text);
                  controller.updateLocalAiEnabled(true);
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.power_settings_new_rounded),
                label: const Text('Mock mode'),
                onPressed: () => controller.updateLocalAiEnabled(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
