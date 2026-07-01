const http = require('node:http');

const DEFAULT_ALLOWED_ORIGINS = [
  'https://de-omega-point.github.io',
  'http://localhost:3000',
  'http://localhost:5000',
  'http://localhost:8080',
  'http://localhost:8081',
];

const ROUTES = new Set([
  '/v1/chat/completions',
  '/v1/audio/transcriptions',
]);

function parseAllowedOrigins(value) {
  if (!value || !value.trim()) return DEFAULT_ALLOWED_ORIGINS;
  return value
      .split(',')
      .map((origin) => origin.trim())
      .filter(Boolean);
}

function normaliseOrigin(origin) {
  if (!origin) return '';
  try {
    return new URL(origin).origin;
  } catch (_) {
    return origin.trim().replace(/\/$/, '');
  }
}

function isOriginAllowed(origin, allowedOrigins) {
  if (!origin) return true;
  if (allowedOrigins.includes('*')) return true;
  return allowedOrigins.map(normaliseOrigin).includes(normaliseOrigin(origin));
}

function sendJson(res, statusCode, body, headers = {}) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Cache-Control': 'no-store',
    ...headers,
  });
  res.end(JSON.stringify(body));
}

function setCorsHeaders(req, res, allowedOrigins) {
  const origin = req.headers.origin;
  if (origin && isOriginAllowed(origin, allowedOrigins)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Vary', 'Origin');
  }
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.setHeader(
      'Access-Control-Allow-Headers',
      'Content-Type,Authorization,Accept',
  );
  res.setHeader('Access-Control-Max-Age', '86400');
}

function readRequestBody(req, maxBodyBytes) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let size = 0;

    req.on('data', (chunk) => {
      size += chunk.length;
      if (size > maxBodyBytes) {
        reject(Object.assign(new Error('Payload too large'), {statusCode: 413}));
        req.destroy();
        return;
      }
      chunks.push(chunk);
    });

    req.on('end', () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}

function cleanBaseUrl(baseUrl) {
  return (baseUrl || 'https://api.groq.com/openai/v1').replace(/\/$/, '');
}

function upstreamUrl(baseUrl, pathname) {
  if (baseUrl.endsWith('/v1') && pathname.startsWith('/v1/')) {
    return `${baseUrl}${pathname.substring(3)}`;
  }
  return `${baseUrl}${pathname}`;
}

function createServer(options = {}) {
  const groqApiKey = options.groqApiKey ?? process.env.GROQ_API_KEY ?? '';
  const groqBaseUrl = cleanBaseUrl(
      options.groqBaseUrl ?? process.env.QIVO_GROQ_BASE_URL,
  );
  const allowedOrigins = parseAllowedOrigins(
      options.allowedOrigins ?? process.env.QIVO_ALLOWED_ORIGINS,
  );
  const maxBodyBytes = Number(
      options.maxBodyBytes ?? process.env.QIVO_MAX_BODY_BYTES ?? 26214400,
  );
  const fetchImpl = options.fetchImpl ?? globalThis.fetch;

  return http.createServer(async (req, res) => {
    setCorsHeaders(req, res, allowedOrigins);

    if (req.method === 'OPTIONS') {
      res.writeHead(204);
      res.end();
      return;
    }

    const requestUrl = new URL(req.url, 'http://qivo.local');
    const pathname = requestUrl.pathname;

    if (req.method === 'GET' && pathname === '/health') {
      sendJson(res, 200, {
        ok: true,
        service: 'qivo-ai-proxy',
        provider: 'groq',
        chat: '/v1/chat/completions',
        transcription: '/v1/audio/transcriptions',
      });
      return;
    }

    if (req.method !== 'POST' || !ROUTES.has(pathname)) {
      sendJson(res, 404, {
        error: 'Not found',
        allowedRoutes: ['/health', ...ROUTES],
      });
      return;
    }

    if (!isOriginAllowed(req.headers.origin, allowedOrigins)) {
      sendJson(res, 403, {error: 'Origin not allowed'});
      return;
    }

    if (!groqApiKey.trim()) {
      sendJson(res, 503, {
        error: 'GROQ_API_KEY is not configured on the proxy server',
      });
      return;
    }

    try {
      const body = await readRequestBody(req, maxBodyBytes);
      const upstream = await fetchImpl(upstreamUrl(groqBaseUrl, pathname), {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${groqApiKey}`,
          Accept: req.headers.accept || 'application/json',
          'Content-Type': req.headers['content-type'] || 'application/json',
        },
        body,
      });

      const responseBody = Buffer.from(await upstream.arrayBuffer());
      res.writeHead(upstream.status, {
        'Content-Type':
          upstream.headers.get('content-type') || 'application/json',
        'Cache-Control': 'no-store',
      });
      res.end(responseBody);
    } catch (error) {
      sendJson(res, error.statusCode || 502, {
        error: 'Proxy request failed',
        detail: error.message,
      });
    }
  });
}

if (require.main === module) {
  const port = Number(process.env.PORT || 8787);
  const server = createServer();
  server.listen(port, () => {
    console.log(`Qivo AI proxy listening on http://localhost:${port}`);
  });
}

module.exports = {
  createServer,
  isOriginAllowed,
  normaliseOrigin,
  parseAllowedOrigins,
  upstreamUrl,
};
