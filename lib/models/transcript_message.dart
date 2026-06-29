enum TranscriptSpeaker {
  you('You'),
  other('Other speaker');

  const TranscriptSpeaker(this.label);
  final String label;
}

class TranscriptMessage {
  const TranscriptMessage({
    required this.speaker,
    required this.text,
    required this.timestamp,
  });

  final TranscriptSpeaker speaker;
  final String text;
  final DateTime timestamp;
}
