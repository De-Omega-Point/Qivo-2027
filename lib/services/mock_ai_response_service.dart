import '../models/ai_suggestion.dart';
import '../models/conversation_state.dart';
import '../models/transcript_message.dart';

abstract class AiResponseService {
  Future<List<AiSuggestion>> suggestionsFor({
    required ConversationState state,
    required List<TranscriptMessage> transcript,
  });
}

class MockAIResponseService implements AiResponseService {
  @override
  Future<List<AiSuggestion>> suggestionsFor({
    required ConversationState state,
    required List<TranscriptMessage> transcript,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final suggestions = switch (state) {
      ConversationState.calm => _calm,
      ConversationState.fast => _fast,
      ConversationState.unclear => _unclear,
      ConversationState.tense => _tense,
      ConversationState.emotionallyLoaded => _loaded,
    };

    return suggestions.take(3).toList();
  }

  static const _calm = [
    AiSuggestion(
      type: SuggestionType.confirm,
      phrase: 'So the next step is a working demo and a clear delivery date.',
      whyItHelps: 'Confirms the shared understanding without adding pressure.',
    ),
    AiSuggestion(
      type: SuggestionType.clarify,
      phrase: 'What would make this feel complete enough for approval?',
      whyItHelps: 'Turns a broad concern into a concrete standard.',
    ),
    AiSuggestion(
      type: SuggestionType.redirect,
      phrase: 'Let us focus on the decision we can make today.',
      whyItHelps: 'Keeps the conversation useful and bounded.',
    ),
  ];

  static const _fast = [
    AiSuggestion(
      type: SuggestionType.pause,
      phrase: 'I want to respond properly, not react quickly.',
      whyItHelps: 'Creates processing time without rejecting the conversation.',
    ),
    AiSuggestion(
      type: SuggestionType.clarify,
      phrase: 'Can you explain what you need from me right now?',
      whyItHelps: 'Finds the immediate ask when the pace is high.',
    ),
    AiSuggestion(
      type: SuggestionType.boundary,
      phrase: 'I am not comfortable making that decision on the spot.',
      whyItHelps: 'Protects the user from agreeing too quickly.',
    ),
  ];

  static const _unclear = [
    AiSuggestion(
      type: SuggestionType.clarify,
      phrase: 'Can we define what success looks like before deciding?',
      whyItHelps: 'Adds shared criteria before commitment.',
    ),
    AiSuggestion(
      type: SuggestionType.confirm,
      phrase: 'I heard two questions: timing and readiness. Is that right?',
      whyItHelps: 'Checks understanding in plain language.',
    ),
    AiSuggestion(
      type: SuggestionType.redirect,
      phrase: 'Which part should we solve first?',
      whyItHelps: 'Reduces overload by creating one next step.',
    ),
  ];

  static const _tense = [
    AiSuggestion(
      type: SuggestionType.deEscalate,
      phrase: 'I want to understand this clearly and keep the conversation useful.',
      whyItHelps: 'Names a cooperative intent without surrendering ground.',
    ),
    AiSuggestion(
      type: SuggestionType.pause,
      phrase: 'I need a short pause before I answer that.',
      whyItHelps: 'Slows the moment down safely.',
    ),
    AiSuggestion(
      type: SuggestionType.boundary,
      phrase: 'I can discuss the timeline, but I cannot commit without checking the details.',
      whyItHelps: 'Sets a firm boundary tied to a reasonable reason.',
    ),
  ];

  static const _loaded = [
    AiSuggestion(
      type: SuggestionType.deEscalate,
      phrase: 'This matters, and I want to answer carefully.',
      whyItHelps: 'Acknowledges emotion without escalating it.',
    ),
    AiSuggestion(
      type: SuggestionType.boundary,
      phrase: 'I can continue if we slow down and stay specific.',
      whyItHelps: 'Creates a clear condition for continuing.',
    ),
    AiSuggestion(
      type: SuggestionType.redirect,
      phrase: 'Can we come back to the specific decision we need to make?',
      whyItHelps: 'Moves from emotional pressure to a concrete topic.',
    ),
  ];
}
