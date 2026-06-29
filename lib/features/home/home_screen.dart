import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/qivo_providers.dart';
import '../../core/theme/qivo_colours.dart';
import '../shell/qivo_components.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(summariesProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QivoCard(
            gradient: true,
            padding: const EdgeInsets.all(26),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 720;
                return Flex(
                  direction: compact ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const QivoLogo(size: 64),
                    SizedBox(width: compact ? 0 : 24, height: compact ? 18 : 0),
                    if (compact)
                      _HeroCopy(ref: ref)
                    else
                      Expanded(child: _HeroCopy(ref: ref)),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 840;
              final cards = [
                _ModeCard(
                  title: 'Prep for a conversation',
                  body: 'Set your goal, tone, boundaries, and key points.',
                  icon: Icons.edit_note_rounded,
                  onTap: () =>
                      ref.read(selectedNavProvider.notifier).state = QivoNavItem.prep,
                ),
                _ModeCard(
                  title: 'Start Live Assist',
                  body: 'Listen privately, see calm suggestions, and pause any time.',
                  icon: Icons.graphic_eq_rounded,
                  onTap: () => ref.read(selectedNavProvider.notifier).state =
                      QivoNavItem.liveAssist,
                ),
                _ModeCard(
                  title: 'Review last conversation',
                  body: 'See decisions, unresolved points, and a next message.',
                  icon: Icons.fact_check_rounded,
                  onTap: () => ref.read(selectedNavProvider.notifier).state =
                      QivoNavItem.review,
                ),
              ];

              if (compact) {
                return Column(
                  children: [
                    for (final card in cards) ...[card, const SizedBox(height: 12)],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final card in cards) ...[
                    Expanded(child: card),
                    if (card != cards.last) const SizedBox(width: 12),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          QivoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Recent conversation',
                  subtitle: 'A quick path back to your latest review.',
                ),
                const SizedBox(height: 16),
                if (summaries.isEmpty)
                  Text(
                    'No saved conversations yet.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: QivoColours.surfaceElevated,
                      child: Icon(Icons.forum_rounded, color: QivoColours.aqua),
                    ),
                    title: Text(summaries.first.title),
                    subtitle: Text(summaries.first.mainTopic),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => ref.read(selectedNavProvider.notifier).state =
                        QivoNavItem.review,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const PrivacyNotice(
            text: 'You control what is saved. Raw audio is off by default.',
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find the right words in real time.',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 10),
        Text(
          'Live conversation support for work, study, appointments, and difficult conversations.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: QivoColours.textSecondary,
              ),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.graphic_eq_rounded),
              label: const Text('Start Live Assist'),
              onPressed: () =>
                  ref.read(selectedNavProvider.notifier).state =
                      QivoNavItem.liveAssist,
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Prep first'),
              onPressed: () =>
                  ref.read(selectedNavProvider.notifier).state = QivoNavItem.prep,
            ),
          ],
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String body;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return QivoCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: QivoColours.aqua, size: 30),
              const SizedBox(height: 14),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(body, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
