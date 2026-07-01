import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import '../models/conversation_state.dart';

abstract class LocalIntelligenceService {
  Future<LocalConversationInsight> analyze(String text);
}

class LocalConversationInsight {
  const LocalConversationInsight({
    required this.conversationState,
    required this.intent,
    required this.source,
    required this.statusMessage,
  });

  final ConversationState conversationState;
  final String intent;
  final String source;
  final String statusMessage;
}

class TransformersLocalIntelligenceService implements LocalIntelligenceService {
  @override
  Future<LocalConversationInsight> analyze(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return _fallback(trimmed);

    try {
      final bridge = js_util.getProperty<Object?>(html.window, 'QivoTransformers');
      if (bridge == null) return _fallback(trimmed);

      final promise = js_util.callMethod<Object>(bridge, 'analyze', [trimmed]);
      final result = await js_util
          .promiseToFuture<Object?>(promise)
          .timeout(const Duration(milliseconds: 1800));
      if (result == null) return _fallback(trimmed);

      final pressure = js_util.getProperty<Object?>(result, 'pressure')?.toString();
      final intent =
          js_util.getProperty<Object?>(result, 'intent')?.toString() ?? 'support';
      final source =
          js_util.getProperty<Object?>(result, 'source')?.toString() ?? 'local';
      return LocalConversationInsight(
        conversationState: _stateFromPressure(pressure),
        intent: intent,
        source: source,
        statusMessage: source == 'transformers'
            ? 'Transformers.js is classifying pressure locally in this browser.'
            : 'Local pressure check is running in fast offline mode.',
      );
    } on Object {
      return _fallback(trimmed);
    }
  }

  LocalConversationInsight _fallback(String text) {
    final lower = text.toLowerCase();
    final state = _heuristicState(lower);
    return LocalConversationInsight(
      conversationState: state,
      intent: _heuristicIntent(lower),
      source: 'heuristic',
      statusMessage: 'Local pressure check is running in fast offline mode.',
    );
  }

  ConversationState _stateFromPressure(String? pressure) {
    return switch (pressure) {
      'fast' => ConversationState.fast,
      'unclear' => ConversationState.unclear,
      'tense' => ConversationState.tense,
      'emotionallyLoaded' => ConversationState.emotionallyLoaded,
      'emotionally_loaded' => ConversationState.emotionallyLoaded,
      _ => ConversationState.calm,
    };
  }

  ConversationState _heuristicState(String lower) {
    final tenseWords = [
      'angry',
      'wrong',
      'unacceptable',
      'blame',
      'fault',
      'never',
      'always',
    ];
    final loadedWords = [
      'upset',
      'hurt',
      'scared',
      'anxious',
      'overwhelmed',
      'sorry',
      'important',
    ];
    final fastWords = [
      'now',
      'urgent',
      'quick',
      'deadline',
      'immediately',
      'asap',
      'today',
    ];
    final unclearWords = [
      'maybe',
      'not sure',
      'confused',
      'unclear',
      'what do you mean',
      'i do not understand',
      'i don\'t understand',
    ];

    if (tenseWords.any(lower.contains)) return ConversationState.tense;
    if (loadedWords.any(lower.contains)) {
      return ConversationState.emotionallyLoaded;
    }
    if (fastWords.any(lower.contains)) return ConversationState.fast;
    if (unclearWords.any(lower.contains) || lower.split('?').length > 2) {
      return ConversationState.unclear;
    }
    return ConversationState.calm;
  }

  String _heuristicIntent(String lower) {
    if (lower.contains('?')) return 'clarify';
    if (lower.contains('decide') || lower.contains('commit')) return 'decision';
    if (lower.contains('sorry') || lower.contains('upset')) return 'repair';
    if (lower.contains('deadline') || lower.contains('urgent')) return 'pace';
    return 'support';
  }
}
