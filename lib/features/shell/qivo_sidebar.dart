import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/qivo_providers.dart';
import '../../core/theme/qivo_colours.dart';
import 'qivo_components.dart';

class QivoSidebar extends ConsumerWidget {
  const QivoSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedNavProvider);

    return Container(
      width: 248,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: const BoxDecoration(
        color: QivoColours.surface,
        border: Border(right: BorderSide(color: QivoColours.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const QivoLogo(),
              const SizedBox(width: 12),
              Text('Qivo', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView.separated(
              itemCount: QivoNavItem.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = QivoNavItem.values[index];
                final isSelected = item == selected;
                return _SidebarItem(
                  item: item,
                  selected: isSelected,
                  onTap: () => ref.read(selectedNavProvider.notifier).state = item,
                );
              },
            ),
          ),
          const QivoStatusBadge(
            label: 'Prototype build',
            color: QivoColours.aqua,
            icon: Icons.science_rounded,
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final QivoNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? QivoColours.primaryBlue.withOpacity(0.18) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: selected ? QivoColours.aqua : QivoColours.textSecondary,
                size: 21,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected
                            ? QivoColours.textPrimary
                            : QivoColours.textSecondary,
                      ),
                ),
              ),
              if (item == QivoNavItem.admin)
                Text(
                  'proto',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
