import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/ai_suggestion.dart';
import '../../models/conversation_state.dart';
import '../../models/conversation_summary.dart';
import '../../models/transcript_message.dart';
import '../../services/ai_backend_config.dart';
import '../../services/browser_speech_transcription_service.dart';
import '../../services/groq_ai_response_service.dart';
import '../../services/mock_ai_response_service.dart';
import '../../services/mock_conversation_service.dart';
import '../../services/mock_transcription_service.dart';
import '../constants/app_constants.dart';

final selectedNavProvider = StateProvider<QivoNavItem>((ref) => QivoNavItem.home);

final settingsProvider =
    StateNotifierProvider<SettingsController, QivoSettings>(
  (ref) => SettingsController(),
);

final aiBackendConfigProvider = Provider<AiBackendConfig>(
  (ref) {
    final settings = ref.watch(settingsProvider);
    return AiBackendConfig.fromEnvironment(
      localFirstEnabled: settings.localAiEnabled,
      localProxyUrl: settings.localAiProxyUrl,
      localModel: settings.localAiModel,
      localSttModel: settings.localSttModel,
    );
  },
);

final aiResponseServiceProvider = Provider<AiResponseService>((ref) {
  final config = ref.watch(aiBackendConfigProvider);
  final fallback = MockAIResponseService();

  if (!config.isConfigured) return fallback;

  return GroqAiResponseService(
    config: config,
    fallback: fallback,
  );
});

class QivoSettings {
  const QivoSettings({
    this.lowStimulusMode = false,
    this.largerText = false,
    this.reduceAnimations = false,
    this.saveRawAudio = false,
    this.saveTranscript = true,
    this.saveSummaries = true,
    this.themeMode = 'Dark',
    this.localAiEnabled = false,
    this.localAiProxyUrl = 'http://localhost:8787',
    this.localAiModel = 'openai/gpt-oss-20b',
    this.localSttModel = 'whisper-large-v3-turbo',
  });

  final bool lowStimulusMode;
  final bool largerText;
  final bool reduceAnimations;
  final bool saveRawAudio;
  final bool saveTranscript;
  final bool saveSummaries;
  final String themeMode;
  final bool localAiEnabled;
  final String localAiProxyUrl;
  final String localAiModel;
  final String localSttModel;

  ThemeMode get resolvedThemeMode {
    return switch (themeMode) {
      'Light' => ThemeMode.light,
      'System' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }

  QivoSettings copyWith({
    bool? lowStimulusMode,
    bool? largerText,
    bool? reduceAnimations,
    bool? saveRawAudio,
    bool? saveTranscript,
    bool? saveSummaries,
    String? themeMode,
    bool? localAiEnabled,
    String? localAiProxyUrl,
    String? localAiModel,
    String? localSttModel,
  }) {
    return QivoSettings(
      lowStimulusMode: lowStimulusMode ?? this.lowStimulusMode,
      largerText: largerText ?? this.largerText,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      saveRawAudio: saveRawAudio ?? this.saveRawAudio,
      saveTranscript: saveTranscript ?? this.saveTranscript,
      saveSummaries: saveSummaries ?? this.saveSummaries,
      themeMode: themeMode ?? this.themeMode,
      localAiEnabled: localAiEnabled ?? this.localAiEnabled,
      localAiProxyUrl: localAiProxyUrl ?? this.localAiProxyUrl,
      localAiModel: localAiModel ?? this.localAiModel,
      localSttModel: localSttModel ?? this.localSttModel,
    );
  }
}

class SettingsController extends StateNotifier<QivoSettings> {
  SettingsController() : super(const QivoSettings());

  void updateLowStimulus(bool value) =>
      state = state.copyWith(lowStimulusMode: value);
  void updateLargerText(bool value) => state = state.copyWith(largerText: value);
  void updateReduceAnimations(bool value) =>
      state = state.copyWith(reduceAnimations: value);
  void updateRawAudio(bool value) => state = state.copyWith(saveRawAudio: value);
  void updateSaveTranscript(bool value) =>
      state = state.copyWith(saveTranscript: value);
  void updateSaveSummaries(bool value) =>
      state = state.copyWith(saveSummaries: value);
  void updateThemeMode(String value) => state = state.copyWith(themeMode: value);
  void updateLocalAiEnabled(bool value) =>
      state = state.copyWith(localAiEnabled: value);
  void updateLocalAiProxyUrl(String value) =>
      state = state.copyWith(localAiProxyUrl: value);
  void updateLocalAiModel(String value) =>
      state = state.copyWith(localAiModel: value);
  void updateLocalSttModel(String value) =>
      state = state.copyWith(localSttModel: value);
}

final liveAssistProvider =
    StateNotifierProvider<LiveAssistController, LiveAssistState>((ref) {
  final controller = LiveAssistController(
    transcriptionService: BrowserSpeechTranscriptionService(),
    aiResponseService: ref.watch(aiResponseServiceProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
});

enum ListeningStatus {
  idle('Ready when you are.'),
  listening('Listening through this browser...'),
  processing('Checking the best short options...'),
  suggesting('Response options ready.'),
  paused('Paused. No audio is being processed.'),
  finished('Conversation finished.');

  const ListeningStatus(this.label);
  final String label;
}

class LiveAssistState {
  const LiveAssistState({
    this.status = ListeningStatus.idle,
    this.transcript = const [],
    this.conversationState = ConversationState.calm,
    this.suggestions = const [],
    this.privacyMessage =
        'Mic audio is used for live transcription. Raw audio is not saved by Qivo.',
  });

  final ListeningStatus status;
  final List<TranscriptMessage> transcript;
  final ConversationState conversationState;
  final List<AiSuggestion> suggestions;
  final String privacyMessage;

  LiveAssistState copyWith({
    ListeningStatus? status,
    List<TranscriptMessage>? transcript,
    ConversationState? conversationState,
    List<AiSuggestion>? suggestions,
    String? privacyMessage,
  }) {
    return LiveAssistState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      conversationState: conversationState ?? this.conversationState,
      suggestions: suggestions ?? this.suggestions,
      privacyMessage: privacyMessage ?? this.privacyMessage,
    );
  }
}

class LiveAssistController extends StateNotifier<LiveAssistState> {
  LiveAssistController({
    required TranscriptionService transcriptionService,
    required AiResponseService aiResponseService,
  })  : _transcriptionService = transcriptionService,
        _aiResponseService = aiResponseService,
        super(const LiveAssistState());

  final TranscriptionService _transcriptionService;
  final AiResponseService _aiResponseService;
  StreamSubscription<TranscriptMessage>? _subscription;

  void start() {
    _subscription?.cancel();
    state = const LiveAssistState(status: ListeningStatus.listening);
    _subscription = _transcriptionService.stream.listen(_handleTranscript);
    _transcriptionService.start();
  }

  void pause() {
    _transcriptionService.pause();
    state = state.copyWith(status: ListeningStatus.paused);
  }

  void resume() {
    _transcriptionService.resume();
    state = state.copyWith(status: ListeningStatus.listening);
  }

  Future<void> triggerSuggestions() async {
    await _loadSuggestions(state.conversationState);
  }

  void quickAction(String action) {
    if (action == 'End conversation') {
      finish();
      return;
    }
    if (action == 'Save moment') {
      state = state.copyWith(
        privacyMessage: 'Moment marked. You still control what is saved.',
      );
      return;
    }
    unawaited(triggerSuggestions());
  }

  void finish() {
    _transcriptionService.stop();
    state = state.copyWith(status: ListeningStatus.finished);
  }

  void reset() {
    _transcriptionService.stop();
    state = const LiveAssistState();
  }

  void setConversationState(ConversationState value) {
    state = state.copyWith(conversationState: value);
    unawaited(_loadSuggestions(value));
  }

  void injectTranscript(String text) {
    final message = TranscriptMessage(
      speaker: TranscriptSpeaker.other,
      text: text,
      timestamp: DateTime.now(),
    );
    _handleTranscript(message);
  }

  void _handleTranscript(TranscriptMessage message) {
    final transcript = [...state.transcript, message];
    final nextState = _stateForTranscript(transcript.length);
    state = state.copyWith(
      status: ListeningStatus.listening,
      transcript: transcript,
      conversationState: nextState,
    );

    if (transcript.length.isEven) {
      unawaited(_loadSuggestions(nextState));
    }
  }

  Future<void> _loadSuggestions(ConversationState conversationState) async {
    if (state.status == ListeningStatus.finished) return;
    state = state.copyWith(status: ListeningStatus.processing);
    final suggestions = await _aiResponseService.suggestionsFor(
      state: conversationState,
      transcript: state.transcript,
    );
    state = state.copyWith(
      status: ListeningStatus.suggesting,
      suggestions: suggestions.take(3).toList(),
    );
  }

  ConversationState _stateForTranscript(int count) {
    final states = ConversationState.values;
    return states[(count ~/ 2) % states.length];
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _transcriptionService.dispose();
    super.dispose();
  }
}

final prepProvider = StateNotifierProvider<PrepController, PrepOutput?>(
  (ref) => PrepController(),
);

class PrepOutput {
  const PrepOutput({
    required this.openingPhrase,
    required this.clarifyingPhrase,
    required this.boundaryPhrase,
    required this.exitPhrase,
    required this.keyPoints,
  });

  final String openingPhrase;
  final String clarifyingPhrase;
  final String boundaryPhrase;
  final String exitPhrase;
  final List<String> keyPoints;
}

class PrepController extends StateNotifier<PrepOutput?> {
  PrepController() : super(null);

  void generate({
    required String person,
    required String topic,
    required String outcome,
    required String tone,
    required List<String> avoid,
  }) {
    final focus = topic.trim().isEmpty ? 'this conversation' : topic.trim();
    final target = outcome.trim().isEmpty ? 'a clear next step' : outcome.trim();
    final withPerson = person.trim().isEmpty ? 'the other person' : person.trim();

    state = PrepOutput(
      openingPhrase:
          'I would like to talk about $focus and keep this clear and useful.',
      clarifyingPhrase:
          'Can you help me understand what you need from me before we decide?',
      boundaryPhrase:
          'I can discuss this now, but I do not want to commit before I have checked the details.',
      exitPhrase:
          'I am going to pause here and follow up in writing so I can be accurate.',
      keyPoints: [
        'Speak with $withPerson in a ${tone.toLowerCase()} tone.',
        'Aim for $target, not a perfect conversation.',
        avoid.isEmpty
            ? 'Pause before agreeing to anything important.'
            : 'Watch for ${avoid.take(2).join(' and ').toLowerCase()}.',
      ],
    );
  }
}

final conversationStoreProvider = Provider<ConversationStore>(
  (ref) => MockConversationService(),
);

final summariesProvider =
    StateNotifierProvider<SummariesController, List<ConversationSummary>>((ref) {
  return SummariesController(ref.watch(conversationStoreProvider));
});

class SummariesController extends StateNotifier<List<ConversationSummary>> {
  SummariesController(this._store) : super(_store.load());

  final ConversationStore _store;

  void saveFromLiveAssist(List<TranscriptMessage> transcript) {
    final summary = ConversationSummary(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: 'Live Assist conversation',
      createdAt: DateTime.now(),
      category: 'Work',
      mainTopic: 'Project timeline and delivery expectations.',
      decision: 'A follow-up demo is needed before final approval.',
      unresolved: 'Delivery date and technical readiness still need confirmation.',
      followUps: const [
        'Send written summary',
        'Request clear next milestone',
        'Confirm technical readiness',
      ],
      suggestedNextMessage:
          'Thanks for the conversation today. To confirm, the next step is a working demo and a clear delivery date.',
      emotionalLoad: transcript.length > 4 ? 4 : 3,
    );
    _store.save(summary);
    state = _store.load();
  }

  void delete(String id) {
    _store.delete(id);
    state = _store.load();
  }

  void clear() {
    _store.clear();
    state = _store.load();
  }
}
