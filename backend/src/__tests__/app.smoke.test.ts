/**
 * Backend smoke tests (no external services).
 *
 * These focus on "does the app boot" and "do our auth modes behave as expected"
 * without requiring Supabase connectivity.
 */

import { describe, expect, it, vi } from 'vitest';
import request from 'supertest';

function setBaseTestEnv(overrides: Record<string, string | undefined> = {}) {
  process.env.PORT = '4000';
  process.env.SUPABASE_URL = 'https://example.supabase.co';
  process.env.SUPABASE_SERVICE_ROLE_KEY = 'test-service-role-key';
  process.env.SUPABASE_JWT_SECRET = 'test-jwt-secret';
  process.env.DEEPSEEK_API_KEY = 'test-deepseek-key';
  process.env.SCAN_API_KEY = '';
  process.env.SCAN_API_URL = 'https://openrouter.ai/api/v1/chat/completions';
  process.env.OPENAI_API_KEY = '';
  process.env.EMBEDDING_MODEL = 'text-embedding-3-small';

  for (const [k, v] of Object.entries(overrides)) {
    if (typeof v === 'undefined') delete process.env[k];
    else process.env[k] = v;
  }
}

async function importFreshApp() {
  // env.ts computes isDevMode at import-time, so reset module cache between cases.
  vi.resetModules();
  const { createApp } = await import('../app');
  return createApp();
}

describe('backend app smoke', () => {
  it('GET /health returns ok', async () => {
    setBaseTestEnv({ NODE_ENV: 'test', ALLOW_DEV_USER: 'false' });
    const app = await importFreshApp();

    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
    expect(res.body.version).toBe('2.0.0');
  });

  it('PROD mode: /api/v1/* requires auth (401 without token)', async () => {
    setBaseTestEnv({ NODE_ENV: 'production', ALLOW_DEV_USER: 'false' });
    const app = await importFreshApp();

    const res = await request(app).get('/api/v1/debug/health');
    expect(res.status).toBe(401);
    expect(String(res.body?.error ?? '')).toMatch(/Authentication required|Invalid/i);
  });

  it('DEV mode: /api/v1/* works without JWT', async () => {
    setBaseTestEnv({
      NODE_ENV: 'development',
      ALLOW_DEV_USER: 'false',
      // Use a real UUID so downstream tables would be happy if touched.
      DEV_USER_ID: '086d851d-1ae0-4d78-8603-d5707156d896',
    });
    const app = await importFreshApp();

    const res = await request(app).get('/api/v1/debug/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toMatch(/ok|degraded/);
    expect(res.body.checks?.env).toBeTruthy();
  });
});

