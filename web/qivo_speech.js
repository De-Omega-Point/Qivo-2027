(function () {
  const SpeechRecognition =
    window.SpeechRecognition || window.webkitSpeechRecognition;

  let recognition = null;
  let active = false;
  let paused = false;

  function dispatch(name, detail) {
    window.dispatchEvent(new CustomEvent(name, { detail }));
  }

  function createRecognition() {
    if (!SpeechRecognition) return null;

    const instance = new SpeechRecognition();
    instance.continuous = true;
    instance.interimResults = false;
    instance.lang = 'en-US';

    instance.onstart = function () {
      dispatch('qivo-speech-status', { status: 'listening' });
    };

    instance.onresult = function (event) {
      for (let index = event.resultIndex; index < event.results.length; index++) {
        const result = event.results[index];
        if (!result.isFinal || !result[0]) continue;

        const text = result[0].transcript.trim();
        if (!text) continue;

        dispatch('qivo-speech-result', {
          text,
          confidence: result[0].confidence || 0,
          isFinal: true
        });
      }
    };

    instance.onerror = function (event) {
      dispatch('qivo-speech-error', {
        error: event.error || 'speech-error',
        message: event.message || ''
      });
    };

    instance.onend = function () {
      dispatch('qivo-speech-status', { status: 'ended' });
      if (active && !paused) {
        window.setTimeout(function () {
          try {
            recognition && recognition.start();
          } catch (_) {}
        }, 250);
      }
    };

    return instance;
  }

  window.QivoSpeech = {
    isSupported: function () {
      return Boolean(SpeechRecognition);
    },
    start: function () {
      if (!SpeechRecognition) {
        dispatch('qivo-speech-error', {
          error: 'unsupported',
          message: 'Browser speech recognition is not available.'
        });
        return false;
      }

      active = true;
      paused = false;
      recognition = recognition || createRecognition();

      try {
        recognition.start();
        return true;
      } catch (_) {
        return true;
      }
    },
    pause: function () {
      paused = true;
      try {
        recognition && recognition.stop();
      } catch (_) {}
    },
    resume: function () {
      if (!active) return this.start();
      paused = false;
      try {
        recognition && recognition.start();
      } catch (_) {}
    },
    stop: function () {
      active = false;
      paused = false;
      try {
        recognition && recognition.stop();
      } catch (_) {}
    }
  };
})();
