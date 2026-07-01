# Qivo AI Backend Choice

## Selected Option

Qivo is configured for a free-start Groq path:

- Live suggestions: `openai/gpt-oss-20b`
- Speech-to-text target: `whisper-large-v3-turbo`
- Fallback: local mock suggestions if no proxy URL is configured or if the API request fails

This keeps the app cheap to test while protecting the live-assist experience from slow responses.

## Why Groq First

- Low latency matters more than maximum model size during a live conversation.
- Groq provides cheap text inference and cheap Whisper transcription in one vendor path.
- The OpenAI-compatible API shape keeps the app portable if we later add DeepSeek, Gemini, or a self-hosted Qwen route.

## Privacy Constraint

Do not put a Groq API key directly into the Flutter web app. Browser builds expose client-side secrets.

Use the included `backend/` proxy or another small backend that:

- Stores `GROQ_API_KEY` server-side.
- Accepts requests from the Qivo web app.
- Forwards chat requests to Groq's OpenAI-compatible `/v1/chat/completions` endpoint.
- Applies rate limits and origin checks before launch.

## Flutter Build Configuration

When a proxy exists, build the app with:

```sh
flutter build web \
  --dart-define=QIVO_AI_PROXY_URL=https://your-qivo-backend.example.com \
  --dart-define=QIVO_AI_MODEL=openai/gpt-oss-20b \
  --dart-define=QIVO_STT_MODEL=whisper-large-v3-turbo
```

If `QIVO_AI_PROXY_URL` is not provided, Qivo stays in mock offline mode.

## Proxy Contract

The Flutter app sends chat `POST` requests to:

```text
{QIVO_AI_PROXY_URL}/v1/chat/completions
```

The proxy also exposes a speech-to-text pass-through endpoint for the next
microphone build:

```text
{QIVO_AI_PROXY_URL}/v1/audio/transcriptions
```

The proxy should accept OpenAI-compatible chat completion bodies and return the normal OpenAI-compatible response:

```json
{
  "choices": [
    {
      "message": {
        "content": "[{\"type\":\"clarify\",\"phrase\":\"Can we slow down and define the next step?\",\"whyItHelps\":\"It reduces pressure and asks for one concrete decision.\"}]"
      }
    }
  ]
}
```

## Next Model Route

After Groq is working, DeepSeek V4 Flash is the best cheap quality fallback for review summaries and harder reasoning moments.

## Deploying The Included Proxy

The backend is dependency-free Node.js and can run on any cheap/free Node host
that supports environment variables.

Required environment variables:

- `GROQ_API_KEY`: server-side Groq key.
- `QIVO_ALLOWED_ORIGINS`: comma-separated browser origins, for example `https://de-omega-point.github.io`.

Optional environment variables:

- `PORT`: default `8787`.
- `QIVO_GROQ_BASE_URL`: default `https://api.groq.com/openai/v1`.
- `QIVO_MAX_BODY_BYTES`: default `26214400`.

Local smoke test:

```sh
cd backend
GROQ_API_KEY=your_key npm start
curl http://localhost:8787/health
```

After the proxy is deployed, set the GitHub repository variable:

```text
QIVO_AI_PROXY_URL=https://your-qivo-backend.example.com
```

The GitHub Pages workflow will pass that URL into the Flutter web build.
