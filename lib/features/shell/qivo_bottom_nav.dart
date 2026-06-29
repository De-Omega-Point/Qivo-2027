import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/qivo_providers.dart';
import '../../core/theme/qivo_colours.dart';
import 'qivo_components.dart';

class QivoBottomNav extends ConsumerWidget {
  const QivoBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedNavProvider);
    const mobileItems = [
      QivoNavItem.home,
      QivoNavItem.liveAssist,
      QivoNavItem.prep,
      QivoNavItem.review,
    ];
    final selectedIndex =
        mobileItems.contains(selected) ? mobileItems.indexOf(selected) : 4;

    return NavigationBar(
      height: 72,
      selectedIndex: selectedIndex,
      backgroundColor: QivoColours.surface,
      indicatorColor: QivoColours.primaryBlue.withOpacity(0.24),
      destinations: [
        for (final item in mobileItems)
          NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.icon, color: QivoColours.aqua),
            label: item.label,
          ),
        const NavigationDestination(
          icon: Icon(Icons.menu_rounded),
          selectedIcon: Icon(Icons.menu_open_rounded, color: QivoColours.aqua),
          label: 'More',
        ),
      ],
      onDestinationSelected: (index) {
        if (index < mobileItems.length) {
          ref.read(selectedNavProvider.notifier).state = mobileItems[index];
          return;
        }
        _showMoreSheet(context, ref);
      },
    );
  }

  void _showMoreSheet(BuildContext context, WidgetRef ref) {
    const moreItems = [
      QivoNavItem.history,
      QivoNavItem.analytics,
      QivoNavItem.settings,
      QivoNavItem.admin,
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: QivoColours.surface,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'More',
                  subtitle: 'History, insights, settings, and prototype tools.',
                ),
                const SizedBox(height: 12),
                for (final item in moreItems)
                  ListTile(
                    minVerticalPadding: 14,
                    leading: Icon(item.icon, color: QivoColours.aqua),
                    title: Text(item.label),
                    subtitle: item == QivoNavItem.admin
                        ? const Text('Prototype-only')
                        : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      ref.read(selectedNavProvider.notifier).state = item;
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
