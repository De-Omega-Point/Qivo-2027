import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/qivo_providers.dart';
import '../../core/theme/qivo_colours.dart';

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
      QivoNavItem.settings,
    ];

    return NavigationBar(
      selectedIndex: mobileItems.contains(selected)
          ? mobileItems.indexOf(selected)
          : mobileItems.indexOf(QivoNavItem.home),
      backgroundColor: QivoColours.surface,
      indicatorColor: QivoColours.primaryBlue.withOpacity(0.24),
      destinations: [
        for (final item in mobileItems)
          NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.icon, color: QivoColours.aqua),
            label: item.label,
          ),
      ],
      onDestinationSelected: (index) {
        ref.read(selectedNavProvider.notifier).state = mobileItems[index];
      },
    );
  }
}
