enum SuggestionType {
  clarify('Clarify'),
  deEscalate('De-escalate'),
  boundary('Boundary'),
  pause('Pause'),
  confirm('Confirm'),
  redirect('Redirect');

  const SuggestionType(this.label);
  final String label;
}

class AiSuggestion {
  const AiSuggestion({
    required this.type,
    required this.phrase,
    required this.whyItHelps,
  });

  final SuggestionType type;
  final String phrase;
  final String whyItHelps;
}
