import '../models/conversation_summary.dart';

abstract class ConversationStore {
  List<ConversationSummary> load();
  void save(ConversationSummary summary);
  void delete(String id);
  void clear();
}

class MockConversationService implements ConversationStore {
  final _summaries = <ConversationSummary>[
    ConversationSummary(
      id: 'demo-1',
      title: 'Project timeline discussion',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      category: 'Work',
      mainTopic: 'Project timeline and delivery expectations.',
      decision: 'A follow-up demo is needed before final approval.',
      unresolved: 'Delivery date and technical readiness still need confirmation.',
      followUps: const [
        'Send written summary',
        'Request clear next milestone',
        'Confirm demo readiness criteria',
      ],
      suggestedNextMessage:
          'Thanks for the conversation today. To confirm, the next step is a working demo and a clear delivery date.',
      emotionalLoad: 3,
    ),
    ConversationSummary(
      id: 'demo-2',
      title: 'Appointment planning',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      category: 'Appointment',
      mainTopic: 'Clarifying preparation and next available times.',
      decision: 'Book a follow-up after checking availability.',
      unresolved: 'Exact time still needs confirmation.',
      followUps: const ['Check calendar', 'Reply with two possible times'],
      suggestedNextMessage:
          'I have checked my calendar. These two times work for me.',
      emotionalLoad: 2,
    ),
  ];

  @override
  List<ConversationSummary> load() => List.unmodifiable(_summaries);

  @override
  void save(ConversationSummary summary) {
    _summaries.insert(0, summary);
  }

  @override
  void delete(String id) {
    _summaries.removeWhere((summary) => summary.id == id);
  }

  @override
  void clear() {
    _summaries.clear();
  }
}
