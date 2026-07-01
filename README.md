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

## AI Proxy

The app includes a deployable Groq proxy in `backend/`. It keeps `GROQ_API_KEY`
server-side and exposes:

- `GET /health`
- `POST /v1/chat/completions`
- `POST /v1/audio/transcriptions`

Run it locally with:

```bash
cd backend
GROQ_API_KEY=your_key npm start
```

After deploying the proxy, add `QIVO_AI_PROXY_URL` as a GitHub repository
variable so the Pages workflow builds the Flutter app against the live backend.

## Local-First AI Test

Run the backend on your Mac:

```bash
cd backend
GROQ_API_KEY=your_key QIVO_ALLOWED_ORIGINS=https://de-omega-point.github.io npm start
```

Then open Qivo, go to Settings, and enable `Use local AI proxy` in the
`Local-first backend` card. The app defaults to:

```text
http://localhost:8787
```

Settings should show `Local test`. Live Assist will call the local proxy for
suggestions and fall back to mock suggestions if the proxy or key is not working
yet.
