import 'package:flutter/material.dart';

import '../../core/theme/qivo_colours.dart';
import '../shell/qivo_components.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Conversations this week', '4', Icons.forum_rounded),
      ('Most used suggestion', 'Clarify', Icons.help_outline_rounded),
      ('Average pressure', 'Medium', Icons.speed_rounded),
      ('Confidence trend', 'Improving', Icons.trending_up_rounded),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QivoCard(
            child: SectionHeader(
              title: 'Personal insights',
              subtitle: 'Simple patterns that support better conversations.',
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 820 ? 4 : 2;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: columns == 4 ? 1.35 : 1.65,
                children: [
                  for (final metric in metrics)
                    QivoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(metric.$3, color: QivoColours.aqua),
                          Text(
                            metric.$2,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(metric.$1),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          QivoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Common trigger'),
                const SizedBox(height: 14),
                for (final trigger in const [
                  ('Fast conversation', 0.72),
                  ('Unclear request', 0.58),
                  ('Conflict', 0.34),
                  ('Decision pressure', 0.66),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trigger.$1),
                        const SizedBox(height: 7),
                        LinearProgressIndicator(
                          value: trigger.$2,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(999),
                          color: QivoColours.aqua,
                          backgroundColor: QivoColours.surfaceElevated,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
