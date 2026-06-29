import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/qivo_providers.dart';
import '../../core/theme/qivo_colours.dart';
import '../../core/utils/responsive.dart';

class QivoLogo extends StatelessWidget {
  const QivoLogo({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          colors: [QivoColours.primaryBlue, QivoColours.violet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: QivoColours.aqua.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        'Q',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: size * 0.52,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class QivoCard extends ConsumerWidget {
  const QivoCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.gradient = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool gradient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isMobile = Responsive.isMobile(context);
    final radius = BorderRadius.circular(isMobile ? 16 : 18);

    return Container(
      padding: isMobile && padding == const EdgeInsets.all(20)
          ? const EdgeInsets.all(16)
          : padding,
      decoration: BoxDecoration(
        color: QivoColours.surface,
        borderRadius: radius,
        border: Border.all(color: QivoColours.border),
        gradient: gradient && !settings.lowStimulusMode
            ? LinearGradient(
                colors: [
                  QivoColours.primaryBlue.withOpacity(0.24),
                  QivoColours.violet.withOpacity(0.20),
                  QivoColours.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: settings.lowStimulusMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: isMobile ? 14 : 24,
                  offset: Offset(0, isMobile ? 8 : 12),
                ),
              ],
      ),
      child: child,
    );
  }
}

class QivoStatusBadge extends StatelessWidget {
  const QivoStatusBadge({
    required this.label,
    required this.color,
    super.key,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: QivoColours.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

class PrivacyNotice extends StatelessWidget {
  const PrivacyNotice({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: QivoColours.aqua.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QivoColours.aqua.withOpacity(0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline_rounded, color: QivoColours.aqua, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}
