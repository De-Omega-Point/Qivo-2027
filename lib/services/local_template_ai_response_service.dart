import '../models/ai_suggestion.dart';
import '../models/conversation_state.dart';
import '../models/transcript_message.dart';
import 'mock_ai_response_service.dart';

class LocalTemplateAiResponseService implements AiResponseService {
  @override
  Future<List<AiSuggestion>> suggestionsFor({
    required ConversationState state,
    required List<TranscriptMessage> transcript,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 90));

    final latest = transcript.isEmpty ? '' : transcript.last.text.toLowerCase();
    final pressureCue = _pressureCue(latest);
    final suggestions = switch (state) {
      ConversationState.calm => _calm(pressureCue),
      ConversationState.fast => _fast(pressureCue),
      ConversationState.unclear => _unclear(pressureCue),
      ConversationState.tense => _tense(pressureCue),
      ConversationState.emotionallyLoaded => _loaded(pressureCue),
    };

    return suggestions;
  }

  String _pressureCue(String latest) {
    if (latest.contains('?')) return 'question';
    if (latest.contains('deadline') || latest.contains('urgent')) {
      return 'deadline';
    }
    if (latest.contains('sorry') || latest.contains('upset')) return 'emotion';
    if (latest.contains('decide') || latest.contains('commit')) {
      return 'decision';
    }
    return 'general';
  }

  List<AiSuggestion> _calm(String cue) => [
        AiSuggestion(
          type: SuggestionType.confirm,
          phrase: cue == 'question'
              ? 'Let me answer the main question first.'
              : 'That matches what I understood too.',
          whyItHelps: 'Keeps a calm conversation clear and moving.',
        ),
        const AiSuggestion(
          type: SuggestionType.clarify,
          phrase: 'What would be the cleanest next step from here?',
          whyItHelps: 'Turns agreement into a practical action.',
        ),
        const AiSuggestion(
          type: SuggestionType.redirect,
          phrase: 'Let us keep this focused on the decision we can make now.',
          whyItHelps: 'Prevents the discussion from spreading too wide.',
        ),
      ];

  List<AiSuggestion> _fast(String cue) => [
        AiSuggestion(
          type: SuggestionType.pause,
          phrase: cue == 'deadline'
              ? 'I hear the timing pressure. I need a moment to answer accurately.'
              : 'I want to respond properly, not rush this.',
          whyItHelps: 'Creates thinking time without shutting the other person down.',
        ),
        const AiSuggestion(
          type: SuggestionType.clarify,
          phrase: 'What do you need from me first?',
          whyItHelps: 'Finds the immediate ask when the pace is high.',
        ),
        const AiSuggestion(
          type: SuggestionType.boundary,
          phrase: 'I cannot commit on the spot, but I can give you the next step.',
          whyItHelps: 'Protects against rushed agreement.',
        ),
      ];

  List<AiSuggestion> _unclear(String cue) => [
        AiSuggestion(
          type: SuggestionType.clarify,
          phrase: cue == 'decision'
              ? 'Before I decide, can we define what success means here?'
              : 'Can we separate the main point from the extra details?',
          whyItHelps: 'Reduces ambiguity before the user responds.',
        ),
        const AiSuggestion(
          type: SuggestionType.confirm,
          phrase: 'I want to check I heard you correctly.',
          whyItHelps: 'Makes misunderstanding easier to catch.',
        ),
        const AiSuggestion(
          type: SuggestionType.redirect,
          phrase: 'Which part should we solve first?',
          whyItHelps: 'Creates one manageable next step.',
        ),
      ];

  List<AiSuggestion> _tense(String cue) => [
        AiSuggestion(
          type: SuggestionType.deEscalate,
          phrase: cue == 'emotion'
              ? 'I can tell this matters, and I want to handle it carefully.'
              : 'I want to understand this without making it harder.',
          whyItHelps: 'Names a cooperative intent while lowering heat.',
        ),
        const AiSuggestion(
          type: SuggestionType.pause,
          phrase: 'I need a short pause before I answer.',
          whyItHelps: 'Slows down a tense moment.',
        ),
        const AiSuggestion(
          type: SuggestionType.boundary,
          phrase: 'I can discuss the issue, but I need us to stay specific.',
          whyItHelps: 'Sets a firm condition for continuing.',
        ),
      ];

  List<AiSuggestion> _loaded(String cue) => [
        AiSuggestion(
          type: SuggestionType.deEscalate,
          phrase: cue == 'emotion'
              ? 'This feels important, and I do not want to answer carelessly.'
              : 'This matters. I want to slow down and be clear.',
          whyItHelps: 'Acknowledges emotional pressure without escalating it.',
        ),
        const AiSuggestion(
          type: SuggestionType.boundary,
          phrase: 'I can continue if we slow down and stay on one point.',
          whyItHelps: 'Creates a clear condition for safety and focus.',
        ),
        const AiSuggestion(
          type: SuggestionType.redirect,
          phrase: 'Can we come back to the specific decision in front of us?',
          whyItHelps: 'Moves from emotion into a concrete next step.',
        ),
      ];
}
