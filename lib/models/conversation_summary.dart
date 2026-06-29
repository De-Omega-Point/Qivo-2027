class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.category,
    required this.mainTopic,
    required this.decision,
    required this.unresolved,
    required this.followUps,
    required this.suggestedNextMessage,
    required this.emotionalLoad,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final String category;
  final String mainTopic;
  final String decision;
  final String unresolved;
  final List<String> followUps;
  final String suggestedNextMessage;
  final int emotionalLoad;
}
