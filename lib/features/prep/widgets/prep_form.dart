import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/qivo_providers.dart';
import '../../../core/theme/qivo_colours.dart';
import '../../shell/qivo_components.dart';

class PrepForm extends ConsumerStatefulWidget {
  const PrepForm({super.key});

  @override
  ConsumerState<PrepForm> createState() => _PrepFormState();
}

class _PrepFormState extends ConsumerState<PrepForm> {
  final _person = TextEditingController();
  final _topic = TextEditingController();
  final _outcome = TextEditingController();
  var _tone = 'Calm';
  final _avoid = <String>{'Overexplaining'};

  static const _tones = ['Calm', 'Clear', 'Firm', 'Warm', 'Professional'];
  static const _avoidOptions = [
    'Conflict',
    'Overexplaining',
    'Agreeing too quickly',
    'Getting overwhelmed',
    'Forgetting key points',
  ];

  @override
  void dispose() {
    _person.dispose();
    _topic.dispose();
    _outcome.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QivoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Prep Coach',
            subtitle: 'Set one goal and keep your phrases simple.',
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _person,
            decoration: const InputDecoration(
              labelText: 'Who are you speaking with?',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _topic,
            decoration: const InputDecoration(
              labelText: 'What is the conversation about?',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _outcome,
            decoration: const InputDecoration(
              labelText: 'What outcome do you want?',
            ),
          ),
          const SizedBox(height: 18),
          Text('Tone', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tone in _tones)
                ChoiceChip(
                  label: Text(tone),
                  selected: _tone == tone,
                  onSelected: (_) => setState(() => _tone = tone),
                  selectedColor: QivoColours.primaryBlue.withOpacity(0.30),
                  backgroundColor: QivoColours.surfaceElevated,
                  side: const BorderSide(color: QivoColours.border),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text('What do you want to avoid?',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in _avoidOptions)
                FilterChip(
                  label: Text(option),
                  selected: _avoid.contains(option),
                  onSelected: (selected) {
                    setState(() {
                      selected ? _avoid.add(option) : _avoid.remove(option);
                    });
                  },
                  selectedColor: QivoColours.violet.withOpacity(0.28),
                  backgroundColor: QivoColours.surfaceElevated,
                  side: const BorderSide(color: QivoColours.border),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Generate Conversation Prep'),
              onPressed: () {
                ref.read(prepProvider.notifier).generate(
                      person: _person.text,
                      topic: _topic.text,
                      outcome: _outcome.text,
                      tone: _tone,
                      avoid: _avoid.toList(),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}
