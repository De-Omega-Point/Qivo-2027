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

Use a small backend proxy that:

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

The Flutter app sends `POST` requests to:

```text
{QIVO_AI_PROXY_URL}/v1/chat/completions
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
