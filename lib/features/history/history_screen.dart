import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/qivo_providers.dart';
import '../../core/theme/qivo_colours.dart';
import '../shell/qivo_components.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  var _query = '';
  var _filter = 'Work';
  static const filters = [
    'Work',
    'Study',
    'Personal',
    'Appointment',
    'Difficult conversation',
  ];

  @override
  Widget build(BuildContext context) {
    final summaries = ref.watch(summariesProvider).where((summary) {
      final matchesQuery = _query.isEmpty ||
          summary.title.toLowerCase().contains(_query.toLowerCase()) ||
          summary.mainTopic.toLowerCase().contains(_query.toLowerCase());
      final matchesFilter = summary.category == _filter;
      return matchesQuery && matchesFilter;
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QivoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Saved conversations',
                  subtitle: 'Search and filter only what you choose to save.',
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    labelText: 'Search conversations',
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final filter in filters)
                      ChoiceChip(
                        label: Text(filter),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                        selectedColor: QivoColours.primaryBlue.withOpacity(0.28),
                        backgroundColor: QivoColours.surfaceElevated,
                        side: const BorderSide(color: QivoColours.border),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (summaries.isEmpty)
            const QivoCard(child: Text('No saved conversations match this view.'))
          else
            for (final summary in summaries) ...[
              QivoCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.forum_rounded, color: QivoColours.aqua),
                  title: Text(summary.title),
                  subtitle: Text(summary.mainTopic),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () =>
                        ref.read(summariesProvider.notifier).delete(summary.id),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 6),
          const PrivacyNotice(
            text: 'Conversation history only includes items you choose to save.',
          ),
        ],
      ),
    );
  }
}
