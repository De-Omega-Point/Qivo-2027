import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/qivo_providers.dart';
import '../../core/theme/qivo_colours.dart';
import '../../models/conversation_state.dart';
import '../shell/qivo_components.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  final _injection = TextEditingController(
    text: 'We need to decide whether the demo is ready today.',
  );
  var _latency = 240.0;

  @override
  void dispose() {
    _injection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final live = ref.watch(liveAssistProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          const QivoCard(
            child: PrivacyNotice(
              text: 'Prototype tools. Not visible to normal users.',
            ),
          ),
          const SizedBox(height: 16),
          QivoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Mock controls'),
                const SizedBox(height: 16),
                Text('Mock latency: ${_latency.round()} ms'),
                Slider(
                  value: _latency,
                  min: 100,
                  max: 2200,
                  divisions: 21,
                  activeColor: QivoColours.aqua,
                  onChanged: (value) => setState(() => _latency = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ConversationState>(
                  value: live.conversationState,
                  decoration: const InputDecoration(
                    labelText: 'Mock conversation pressure',
                  ),
                  items: [
                    for (final state in ConversationState.values)
                      DropdownMenuItem(
                        value: state,
                        child: Text(state.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(liveAssistProvider.notifier)
                          .setConversationState(value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _injection,
                  decoration: const InputDecoration(
                    labelText: 'Mock transcript injection',
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.input_rounded),
                      label: const Text('Inject transcript'),
                      onPressed: () => ref
                          .read(liveAssistProvider.notifier)
                          .injectTranscript(_injection.text),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('Trigger AI response'),
                      onPressed: () => ref
                          .read(liveAssistProvider.notifier)
                          .triggerSuggestions(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          QivoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Debug logs'),
                const SizedBox(height: 12),
                _LogLine(label: 'Backend connection', value: 'Mock offline mode'),
                _LogLine(label: 'Listening status', value: live.status.label),
                _LogLine(
                  label: 'Transcript messages',
                  value: live.transcript.length.toString(),
                ),
                _LogLine(
                  label: 'Suggestions visible',
                  value: live.suggestions.length.toString(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogLine extends StatelessWidget {
  const _LogLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
