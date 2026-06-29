import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/qivo_providers.dart';
import '../../../core/theme/qivo_colours.dart';
import '../../shell/qivo_components.dart';

class ListeningPanel extends ConsumerWidget {
  const ListeningPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveAssistProvider);
    final controller = ref.read(liveAssistProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final active = live.status == ListeningStatus.listening ||
        live.status == ListeningStatus.processing ||
        live.status == ListeningStatus.suggesting;

    return QivoCard(
      gradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Pulse(active: active && !settings.reduceAnimations),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Live Assist',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      live.status.label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                icon: Icon(
                  live.status == ListeningStatus.paused
                      ? Icons.play_arrow_rounded
                      : Icons.mic_rounded,
                ),
                label: Text(_primaryLabel(live.status)),
                onPressed: () {
                  if (live.status == ListeningStatus.paused) {
                    controller.resume();
                  } else {
                    controller.start();
                  }
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.pause_rounded),
                label: const Text('Pause'),
                onPressed: active ? controller.pause : null,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.stop_rounded),
                label: const Text('End conversation'),
                onPressed: live.status == ListeningStatus.idle
                    ? null
                    : controller.finish,
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrivacyNotice(text: live.privacyMessage),
        ],
      ),
    );
  }

  String _primaryLabel(ListeningStatus status) {
    return switch (status) {
      ListeningStatus.idle => 'Start listening',
      ListeningStatus.paused => 'Resume',
      ListeningStatus.finished => 'Start new',
      _ => 'Restart',
    };
  }
}

class _Pulse extends StatelessWidget {
  const _Pulse({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.72, end: active ? 1 : 0.72),
      duration: active ? const Duration(milliseconds: 900) : Duration.zero,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? QivoColours.liveGreen.withOpacity(0.12 + value * 0.12)
                : QivoColours.surfaceElevated,
            border: Border.all(
              color: active ? QivoColours.liveGreen : QivoColours.border,
              width: 1.4,
            ),
          ),
          child: Icon(
            active ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
            color: active ? QivoColours.liveGreen : QivoColours.textSecondary,
          ),
        );
      },
    );
  }
}
