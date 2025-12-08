/**
 * EverForm Backend Server
 * 
 * Express API with auth and rate limiting.
 * 
 * DEV MODE: NODE_ENV=development OR ALLOW_DEV_USER=true
 *   → All /api/v1/* routes work without JWT
 *   → Uses dev-user-0001 for all requests
 * 
 * PROD MODE: Otherwise
 *   → All /api/v1/* routes require valid JWT
 */

import cors from 'cors';
import express, { NextFunction, Request, Response } from 'express';
import { ZodError } from 'zod';
import { env, isDevMode, DEV_USER_ID } from './config/env';
import { authMiddleware } from './middleware/auth';
import routes from './routes/index';
import coachRouter from './routes/publicCoach';
import scanRouter from './routes/publicScan';

const app = express();

// ─────────────────────────────────────────────────────────────────────────────
// MIDDLEWARE
// ─────────────────────────────────────────────────────────────────────────────

app.use(cors({ origin: true, credentials: true }));
app.use(express.json({ limit: '10mb' }));

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC HEALTH ENDPOINT (no auth)
// ─────────────────────────────────────────────────────────────────────────────

app.get('/health', (_req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(), 
    version: '2.0.0',
    mode: isDevMode ? 'development' : 'production'
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// AI ENDPOINTS (auth + rate limited)
// /api/coach/chat, /api/scan/food, /api/scan/test
// ─────────────────────────────────────────────────────────────────────────────

app.use('/api/coach', coachRouter);
app.use('/api/scan', scanRouter);

// ─────────────────────────────────────────────────────────────────────────────
// AUTHENTICATED ROUTES under /api/v1
// All routes here go through authMiddleware
// ─────────────────────────────────────────────────────────────────────────────

app.use('/api/v1', authMiddleware, routes);

// ─────────────────────────────────────────────────────────────────────────────
// ERROR HANDLER
// ─────────────────────────────────────────────────────────────────────────────

app.use((err: unknown, _req: Request, res: Response, _next: NextFunction) => {
  if (err instanceof ZodError) {
    return res.status(400).json({ 
      error: 'Validation failed', 
      issues: err.issues
    });
  }

  console.error('[server] Unhandled error:', err);
  return res.status(500).json({ error: 'Internal server error' });
});

// ─────────────────────────────────────────────────────────────────────────────
// START
// ─────────────────────────────────────────────────────────────────────────────

const port = env.PORT;

app.listen(port, () => {
  console.log('');
  console.log('╔═══════════════════════════════════════════════════════════╗');
  console.log('║           EverForm Backend v2.0.0                         ║');
  console.log('╠═══════════════════════════════════════════════════════════╣');
  console.log(`║  🌐 Server:      http://localhost:${port}                     ║`);
  console.log(`║  📦 NODE_ENV:    ${env.NODE_ENV.padEnd(39)}║`);
  
  if (isDevMode) {
    console.log('║  🔓 Auth Mode:   DEV (no JWT required)                     ║');
    console.log(`║  👤 Dev User:    ${DEV_USER_ID.padEnd(39)}║`);
  } else {
    console.log('║  🔒 Auth Mode:   PRODUCTION (JWT required)                 ║');
  }
  
  console.log('╠═══════════════════════════════════════════════════════════╣');
  console.log('║  ENDPOINTS                                                ║');
  console.log('╠═══════════════════════════════════════════════════════════╣');
  console.log('║  Public:                                                  ║');
  console.log('║    GET  /health                                           ║');
  console.log('║                                                           ║');
  console.log('║  AI (auth + rate limited):                                ║');
  console.log('║    POST /api/coach/chat                                   ║');
  console.log('║    POST /api/scan/food                                    ║');
  console.log('║                                                           ║');
  console.log('║  User Data (/api/v1/*):                                   ║');
  console.log('║    GET  /api/v1/profile                                   ║');
  console.log('║    GET  /api/v1/dashboard/today                           ║');
  console.log('║    GET  /api/v1/nutrition/summary                         ║');
  console.log('║    POST /api/v1/training/log                              ║');
  console.log('║    POST /api/v1/recovery/log                              ║');
  console.log('║    ... and more (see routes/index.ts)                     ║');
  console.log('╚═══════════════════════════════════════════════════════════╝');
  console.log('');
  
  if (isDevMode) {
    console.log('  ✅ iOS app can call /api/v1/* without auth token');
    console.log('');
  }
});
