import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/qivo_providers.dart';
import '../../../core/theme/qivo_colours.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/conversation_state.dart';
import '../../shell/qivo_components.dart';

class ListeningPanel extends ConsumerWidget {
  const ListeningPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveAssistProvider);
    final controller = ref.read(liveAssistProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final isMobile = Responsive.isMobile(context);
    final active = live.status == ListeningStatus.listening ||
        live.status == ListeningStatus.processing ||
        live.status == ListeningStatus.suggesting;
    void primaryAction() {
      if (live.status == ListeningStatus.paused) {
        controller.resume();
      } else {
        controller.start();
      }
    }

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
          const SizedBox(height: 16),
          _MoodLineIndicator(
            current: live.conversationState,
            compact: isMobile,
            animate: !settings.reduceAnimations,
          ),
          const SizedBox(height: 18),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LogoMicButton(
                  active: active,
                  label: Text(_primaryLabel(live.status)),
                  onPressed: primaryAction,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.pause_rounded),
                        label: const Text('Pause'),
                        onPressed: active ? controller.pause : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.stop_rounded),
                        label: const Text('End'),
                        onPressed: live.status == ListeningStatus.idle
                            ? null
                            : controller.finish,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _LogoMicButton(
                  active: active,
                  label: Text(_primaryLabel(live.status)),
                  onPressed: primaryAction,
                  compact: true,
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

class _MoodLineIndicator extends StatelessWidget {
  const _MoodLineIndicator({
    required this.current,
    required this.compact,
    required this.animate,
  });

  final ConversationState current;
  final bool compact;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final states = ConversationState.values;

    return Semantics(
      label: 'Current conversation pressure is ${current.label}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Conversation pressure',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  color: QivoColours.border,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  current.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: current.color,
                      ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              for (var index = 0; index < states.length; index++) ...[
                Expanded(
                  child: _MoodSegment(
                    state: states[index],
                    selected: states[index] == current,
                    compact: compact,
                    animate: animate,
                  ),
                ),
                if (index != states.length - 1) const SizedBox(width: 5),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodSegment extends StatelessWidget {
  const _MoodSegment({
    required this.state,
    required this.selected,
    required this.compact,
    required this.animate,
  });

  final ConversationState state;
  final bool selected;
  final bool compact;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animate ? const Duration(milliseconds: 240) : Duration.zero,
      height: selected ? (compact ? 9 : 10) : (compact ? 6 : 7),
      decoration: BoxDecoration(
        color: selected ? state.color : state.color.withOpacity(0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? state.color : state.color.withOpacity(0.18),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: state.color.withOpacity(0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
    );
  }
}

class _LogoMicButton extends StatelessWidget {
  const _LogoMicButton({
    required this.active,
    required this.label,
    required this.onPressed,
    this.compact = false,
  });

  final bool active;
  final Widget label;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 42.0 : 58.0;

    return Material(
      color: active
          ? QivoColours.liveGreen.withOpacity(0.10)
          : QivoColours.primaryBlue.withOpacity(0.16),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: BoxConstraints(
            minHeight: compact ? 54 : 68,
            minWidth: compact ? 190 : 0,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 16,
            vertical: compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active
                  ? QivoColours.liveGreen.withOpacity(0.48)
                  : QivoColours.aqua.withOpacity(0.34),
            ),
          ),
          child: Row(
            mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment:
                compact ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  QivoLogo(size: logoSize),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      width: compact ? 20 : 24,
                      height: compact ? 20 : 24,
                      decoration: BoxDecoration(
                        color: active
                            ? QivoColours.liveGreen
                            : QivoColours.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: QivoColours.textPrimary.withOpacity(0.28),
                        ),
                      ),
                      child: Icon(
                        active
                            ? Icons.graphic_eq_rounded
                            : Icons.mic_none_rounded,
                        color: active
                            ? QivoColours.background
                            : QivoColours.aqua,
                        size: compact ? 13 : 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Flexible(
                child: DefaultTextStyle.merge(
                  style: Theme.of(context).textTheme.labelLarge,
                  child: label,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
