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
              _StateDot(
                color: _statusColorFor(live.status),
                active: active && !settings.reduceAnimations,
              ),
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
                  status: live.status,
                  label: _primaryLabel(live.status),
                  hint: _primaryHint(live.status),
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
                  status: live.status,
                  label: _primaryLabel(live.status),
                  hint: _primaryHint(live.status),
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

  String _primaryHint(ListeningStatus status) {
    return switch (status) {
      ListeningStatus.idle => 'Tap the logo to begin',
      ListeningStatus.listening => 'Live. Tap to restart',
      ListeningStatus.processing => 'Checking options',
      ListeningStatus.suggesting => 'Suggestions ready',
      ListeningStatus.paused => 'Tap the logo to resume',
      ListeningStatus.finished => 'Tap for a new session',
    };
  }

}

Color _statusColorFor(ListeningStatus status) {
  return switch (status) {
    ListeningStatus.idle => QivoColours.aqua,
    ListeningStatus.listening => QivoColours.liveGreen,
    ListeningStatus.processing => QivoColours.aqua,
    ListeningStatus.suggesting => QivoColours.violet,
    ListeningStatus.paused => QivoColours.warningAmber,
    ListeningStatus.finished => QivoColours.mutedText,
  };
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
    final palette = context.qivoPalette;

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
                  color: palette.border,
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
    required this.status,
    required this.label,
    required this.hint,
    required this.onPressed,
    this.compact = false,
  });

  final ListeningStatus status;
  final String label;
  final String hint;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.qivoPalette;
    final color = _statusColorFor(status);
    final active = status == ListeningStatus.listening ||
        status == ListeningStatus.processing ||
        status == ListeningStatus.suggesting;
    final logoSize = compact ? 42.0 : 72.0;
    final borderRadius = BorderRadius.circular(compact ? 18 : 24);

    return Material(
      color: color.withOpacity(active ? 0.14 : 0.10),
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Container(
          constraints: BoxConstraints(
            minHeight: compact ? 54 : 104,
            minWidth: compact ? 190 : 0,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 18,
            vertical: compact ? 8 : 14,
          ),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: color.withOpacity(active ? 0.62 : 0.42),
              width: active ? 1.4 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
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
                      width: compact ? 20 : 28,
                      height: compact ? 20 : 28,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: palette.textPrimary.withOpacity(0.28),
                        ),
                      ),
                      child: Icon(
                        active
                            ? Icons.graphic_eq_rounded
                            : Icons.mic_none_rounded,
                        color: palette.background,
                        size: compact ? 13 : 17,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: compact
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: palette.textPrimary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 4),
                      Text(
                        hint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: palette.textSecondary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _StateDot extends StatelessWidget {
  const _StateDot({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final palette = context.qivoPalette;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.72, end: active ? 1 : 0.72),
      duration: active ? const Duration(milliseconds: 900) : Duration.zero,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(active ? 0.10 + value * 0.10 : 0.08),
            border: Border.all(
              color: active ? color : palette.border,
              width: 1.4,
            ),
          ),
          child: Icon(
            active ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
            color: active ? color : palette.textSecondary,
            size: 20,
          ),
        );
      },
    );
  }
}
