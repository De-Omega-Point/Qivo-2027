import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import '../models/transcript_message.dart';
import 'mock_transcription_service.dart';

class BrowserSpeechTranscriptionService implements TranscriptionService {
  BrowserSpeechTranscriptionService({
    TranscriptionService? fallback,
  }) : _fallback = fallback ?? MockTranscriptionService();

  final _controller = StreamController<TranscriptMessage>.broadcast();
  final TranscriptionService _fallback;
  final _fallbackSubscriptions = <StreamSubscription<TranscriptMessage>>[];
  StreamSubscription<html.Event>? _resultSubscription;
  StreamSubscription<html.Event>? _errorSubscription;
  var _usingFallback = false;

  @override
  Stream<TranscriptMessage> get stream => _controller.stream;

  @override
  void start() {
    _stopFallback();
    _usingFallback = false;
    _listenToBrowserEvents();

    final qivoSpeech = js_util.getProperty<Object?>(html.window, 'QivoSpeech');
    if (qivoSpeech == null ||
        js_util.callMethod<bool>(qivoSpeech, 'isSupported', const []) == false) {
      _startFallback('Speech recognition is not available in this browser.');
      return;
    }

    final started = js_util.callMethod<bool>(qivoSpeech, 'start', const []);
    if (!started) {
      _startFallback('Microphone speech capture could not start.');
    }
  }

  @override
  void pause() {
    if (_usingFallback) {
      _fallback.pause();
      return;
    }

    final qivoSpeech = js_util.getProperty<Object?>(html.window, 'QivoSpeech');
    if (qivoSpeech != null) {
      js_util.callMethod<void>(qivoSpeech, 'pause', const []);
    }
  }

  @override
  void resume() {
    if (_usingFallback) {
      _fallback.resume();
      return;
    }

    final qivoSpeech = js_util.getProperty<Object?>(html.window, 'QivoSpeech');
    if (qivoSpeech != null) {
      js_util.callMethod<void>(qivoSpeech, 'resume', const []);
    }
  }

  @override
  void stop() {
    final qivoSpeech = js_util.getProperty<Object?>(html.window, 'QivoSpeech');
    if (qivoSpeech != null) {
      js_util.callMethod<void>(qivoSpeech, 'stop', const []);
    }
    _stopFallback();
  }

  void _listenToBrowserEvents() {
    _resultSubscription ??=
        html.window.on['qivo-speech-result'].listen(_handleSpeechResult);
    _errorSubscription ??=
        html.window.on['qivo-speech-error'].listen(_handleSpeechError);
  }

  void _handleSpeechResult(html.Event event) {
    if (_controller.isClosed) return;

    final detail = js_util.getProperty<Object?>(event, 'detail');
    final text = detail == null
        ? ''
        : js_util.getProperty<Object?>(detail, 'text')?.toString().trim() ?? '';

    if (text.isEmpty) return;

    _controller.add(
      TranscriptMessage(
        speaker: TranscriptSpeaker.you,
        text: text,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _handleSpeechError(html.Event event) {
    if (_controller.isClosed || _usingFallback) return;

    final detail = js_util.getProperty<Object?>(event, 'detail');
    final error = detail == null
        ? 'speech-error'
        : js_util.getProperty<Object?>(detail, 'error')?.toString() ??
            'speech-error';

    if (error == 'no-speech') return;

    _startFallback('Speech capture issue: $error.');
  }

  void _startFallback(String reason) {
    if (_controller.isClosed) return;
    final qivoSpeech = js_util.getProperty<Object?>(html.window, 'QivoSpeech');
    if (qivoSpeech != null) {
      js_util.callMethod<void>(qivoSpeech, 'stop', const []);
    }
    _usingFallback = true;
    _controller.add(
      TranscriptMessage(
        speaker: TranscriptSpeaker.other,
        text: '$reason Qivo is using the demo transcript so the app remains usable.',
        timestamp: DateTime.now(),
      ),
    );
    _fallbackSubscriptions.add(
      _fallback.stream.listen((message) {
        if (!_controller.isClosed) _controller.add(message);
      }),
    );
    _fallback.start();
  }

  void _stopFallback() {
    for (final subscription in _fallbackSubscriptions) {
      unawaited(subscription.cancel());
    }
    _fallbackSubscriptions.clear();
    _fallback.stop();
  }

  @override
  void dispose() {
    stop();
    unawaited(_resultSubscription?.cancel());
    unawaited(_errorSubscription?.cancel());
    _fallback.dispose();
    _controller.close();
  }
}
