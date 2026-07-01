const assert = require('node:assert/strict');
const test = require('node:test');

const {
  createServer,
  isOriginAllowed,
  parseAllowedOrigins,
  upstreamUrl,
} = require('./server');

function listen(server) {
  return new Promise((resolve) => {
    server.listen(0, () => {
      resolve(`http://127.0.0.1:${server.address().port}`);
    });
  });
}

test('parses comma-separated allowed origins', () => {
  assert.deepEqual(parseAllowedOrigins('https://a.com, http://localhost:8080'), [
    'https://a.com',
    'http://localhost:8080',
  ]);
});

test('allows matching origins and blocks unknown origins', () => {
  const allowed = ['https://de-omega-point.github.io'];

  assert.equal(
      isOriginAllowed('https://de-omega-point.github.io/Qivo-2027/', allowed),
      true,
  );
  assert.equal(isOriginAllowed('https://example.com', allowed), false);
});

test('health endpoint returns proxy status', async () => {
  const server = createServer({groqApiKey: ''});
  const baseUrl = await listen(server);

  try {
    const response = await fetch(`${baseUrl}/health`);
    const body = await response.json();

    assert.equal(response.status, 200);
    assert.equal(body.ok, true);
    assert.equal(body.service, 'qivo-ai-proxy');
  } finally {
    server.close();
  }
});

test('builds clean Groq upstream URLs', () => {
  assert.equal(
      upstreamUrl('https://api.groq.com/openai/v1', '/v1/chat/completions'),
      'https://api.groq.com/openai/v1/chat/completions',
  );
  assert.equal(
      upstreamUrl('https://proxy.example.com', '/v1/chat/completions'),
      'https://proxy.example.com/v1/chat/completions',
  );
});

test('chat endpoint requires server-side Groq key', async () => {
  const server = createServer({groqApiKey: '', allowedOrigins: '*'});
  const baseUrl = await listen(server);

  try {
    const response = await fetch(`${baseUrl}/v1/chat/completions`, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({messages: []}),
    });
    const body = await response.json();

    assert.equal(response.status, 503);
    assert.match(body.error, /GROQ_API_KEY/);
  } finally {
    server.close();
  }
});

test('chat endpoint forwards OpenAI-compatible body to Groq', async () => {
  const server = createServer({
    groqApiKey: 'test-key',
    allowedOrigins: '*',
    fetchImpl: async (url, init) => {
      assert.equal(url, 'https://api.groq.com/openai/v1/chat/completions');
      assert.equal(init.method, 'POST');
      assert.equal(init.headers.Authorization, 'Bearer test-key');

      return new Response(
          JSON.stringify({choices: [{message: {content: '[]'}}]}),
          {status: 200, headers: {'Content-Type': 'application/json'}},
      );
    },
  });
  const baseUrl = await listen(server);

  try {
    const response = await fetch(`${baseUrl}/v1/chat/completions`, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({messages: []}),
    });

    assert.equal(response.status, 200);
  } finally {
    server.close();
  }
});
