import 'dart:async';

import '../models/transcript_message.dart';

abstract class TranscriptionService {
  Stream<TranscriptMessage> get stream;
  void start();
  void pause();
  void resume();
  void stop();
  void dispose();
}

class MockTranscriptionService implements TranscriptionService {
  final _controller = StreamController<TranscriptMessage>.broadcast();
  Timer? _timer;
  var _index = 0;
  var _isPaused = false;

  static const _samples = <({TranscriptSpeaker speaker, String text})>[
    (
      speaker: TranscriptSpeaker.other,
      text: 'I understand what you are saying, but we need to decide today.',
    ),
    (
      speaker: TranscriptSpeaker.you,
      text: 'I need a moment to process that before I answer.',
    ),
    (
      speaker: TranscriptSpeaker.other,
      text: 'The timeline feels tight and I need to know what is realistic.',
    ),
    (
      speaker: TranscriptSpeaker.you,
      text: 'Can we separate the delivery date from the demo readiness?',
    ),
    (
      speaker: TranscriptSpeaker.other,
      text: 'That makes sense. What would you need to confirm first?',
    ),
    (
      speaker: TranscriptSpeaker.you,
      text: 'I can confirm the next milestone if we define the success criteria.',
    ),
  ];

  @override
  Stream<TranscriptMessage> get stream => _controller.stream;

  @override
  void start() {
    stop();
    _index = 0;
    _isPaused = false;
    _emit();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _emit());
  }

  @override
  void pause() {
    _isPaused = true;
  }

  @override
  void resume() {
    _isPaused = false;
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _emit() {
    if (_isPaused || _controller.isClosed) return;
    final sample = _samples[_index % _samples.length];
    _index += 1;
    _controller.add(
      TranscriptMessage(
        speaker: sample.speaker,
        text: sample.text,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    stop();
    _controller.close();
  }
}
