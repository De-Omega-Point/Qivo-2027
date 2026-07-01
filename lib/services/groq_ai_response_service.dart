import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ai_suggestion.dart';
import '../models/conversation_state.dart';
import '../models/transcript_message.dart';
import 'ai_backend_config.dart';
import 'mock_ai_response_service.dart';

class GroqAiResponseService implements AiResponseService {
  GroqAiResponseService({
    required AiBackendConfig config,
    required AiResponseService fallback,
    http.Client? client,
  })  : _config = config,
        _fallback = fallback,
        _client = client ?? http.Client();

  final AiBackendConfig _config;
  final AiResponseService _fallback;
  final http.Client _client;

  @override
  Future<List<AiSuggestion>> suggestionsFor({
    required ConversationState state,
    required List<TranscriptMessage> transcript,
  }) async {
    if (!_config.isConfigured) {
      return _fallback.suggestionsFor(state: state, transcript: transcript);
    }

    try {
      final response = await _client
          .post(
            _chatCompletionsUri(_config.proxyUrl),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': _config.model,
              'temperature': 0.35,
              'max_tokens': 260,
              'messages': [
                {
                  'role': 'system',
                  'content': _systemPrompt,
                },
                {
                  'role': 'user',
                  'content': _buildUserPrompt(state, transcript),
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _fallback.suggestionsFor(state: state, transcript: transcript);
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>? ?? const [];
      if (choices.isEmpty) {
        return _fallback.suggestionsFor(state: state, transcript: transcript);
      }

      final message = choices.first as Map<String, dynamic>;
      final content = (message['message'] as Map<String, dynamic>?)?['content'];
      if (content is! String || content.trim().isEmpty) {
        return _fallback.suggestionsFor(state: state, transcript: transcript);
      }

      final suggestions = _parseSuggestions(content);
      if (suggestions.isEmpty) {
        return _fallback.suggestionsFor(state: state, transcript: transcript);
      }

      return suggestions.take(3).toList();
    } on Object {
      return _fallback.suggestionsFor(state: state, transcript: transcript);
    }
  }

  Uri _chatCompletionsUri(String proxyUrl) {
    final trimmed = proxyUrl.trim();
    if (trimmed.endsWith('/chat/completions')) {
      return Uri.parse(trimmed);
    }

    final withoutSlash = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final path = withoutSlash.endsWith('/v1')
        ? '$withoutSlash/chat/completions'
        : '$withoutSlash/v1/chat/completions';
    return Uri.parse(path);
  }

  String _buildUserPrompt(
    ConversationState state,
    List<TranscriptMessage> transcript,
  ) {
    final recent = transcript.take(8).map((message) {
      final speaker = message.speaker == TranscriptSpeaker.you ? 'User' : 'Other';
      return '$speaker: ${message.text}';
    }).join('\n');

    return '''
Conversation pressure: ${state.label}
Recent transcript:
${recent.isEmpty ? 'No transcript yet.' : recent}

Return exactly 3 options. Each option must be short enough to read while speaking.
''';
  }

  List<AiSuggestion> _parseSuggestions(String content) {
    final jsonText = _extractJson(content);
    final decoded = jsonDecode(jsonText);
    final items = decoded is List<dynamic>
        ? decoded
        : (decoded as Map<String, dynamic>)['suggestions'] as List<dynamic>? ??
            const [];

    return [
      for (final item in items)
        if (item is Map<String, dynamic>)
          AiSuggestion(
            type: _typeFromLabel(item['type']?.toString()),
            phrase: item['phrase']?.toString() ?? '',
            whyItHelps: item['whyItHelps']?.toString() ??
                item['why_it_helps']?.toString() ??
                '',
          ),
    ].where((suggestion) {
      return suggestion.phrase.trim().isNotEmpty &&
          suggestion.whyItHelps.trim().isNotEmpty;
    }).toList();
  }

  String _extractJson(String content) {
    final trimmed = content.trim();
    if (trimmed.startsWith('[') || trimmed.startsWith('{')) return trimmed;

    final arrayStart = trimmed.indexOf('[');
    final arrayEnd = trimmed.lastIndexOf(']');
    if (arrayStart >= 0 && arrayEnd > arrayStart) {
      return trimmed.substring(arrayStart, arrayEnd + 1);
    }

    final objectStart = trimmed.indexOf('{');
    final objectEnd = trimmed.lastIndexOf('}');
    if (objectStart >= 0 && objectEnd > objectStart) {
      return trimmed.substring(objectStart, objectEnd + 1);
    }

    throw const FormatException('No JSON suggestions found.');
  }

  SuggestionType _typeFromLabel(String? label) {
    final normalised = label?.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    return switch (normalised) {
      'deescalate' => SuggestionType.deEscalate,
      'boundary' => SuggestionType.boundary,
      'pause' => SuggestionType.pause,
      'confirm' => SuggestionType.confirm,
      'redirect' => SuggestionType.redirect,
      _ => SuggestionType.clarify,
    };
  }

  static const _systemPrompt = '''
You are Qivo, a low-latency live conversation assistant.
Generate calm, practical lines the user can say out loud.
Never diagnose, shame, manipulate, or escalate.
Prefer concise phrases, plain language, and pressure-reducing boundaries.
Return only JSON:
[
  {"type":"clarify|deEscalate|boundary|pause|confirm|redirect","phrase":"...","whyItHelps":"..."}
]
''';
}
