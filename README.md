# Qivo 2027

Qivo is a Flutter MVP for a real-time AI conversation assistant.

Core promise: **Qivo helps you understand the conversation and know what to say next.**

## Run

This repo contains the Flutter app source, web entrypoint, mock services, and app assets folder.

```bash
flutter pub get
flutter run -d chrome
```

For mobile and desktop runners, use a current stable Flutter SDK and generate platform folders if they are not present:

```bash
flutter create --platforms=ios,android,web,macos,windows,linux .
```

## Asset Setup

Place the Qivo logo at:

```text
assets/images/qivo_logo.png
```

The current MVP renders a branded in-app fallback mark so the interface remains usable if the PNG is not available yet.

## Architecture

- `lib/core` contains theme tokens, constants, responsive helpers, and Riverpod app state.
- `lib/models` contains transcript, suggestion, conversation state, and summary models.
- `lib/services` contains mock transcription, AI suggestion, and conversation storage services behind simple interfaces.
- `lib/features` contains the adaptive shell and the Home, Live Assist, Prep, Review, History, Analytics, Settings, and Admin screens.

Future backend integration points are isolated behind services:

- STT and WebSocket audio streaming replace `TranscriptionService`.
- LLM response generation replaces `AiResponseService`.
- Speaker recognition and voice enrolment can enrich `TranscriptMessage`.
- Supabase auth, storage, and secure history replace `ConversationStore`.
- Stripe subscription can be added at the shell/account boundary without changing core Live Assist UX.
