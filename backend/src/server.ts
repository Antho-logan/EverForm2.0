/**
 * EverForm Backend Server (entrypoint)
 *
 * Starts the HTTP listener for the configured Express app.
 *
 * DEV MODE: NODE_ENV=development OR ALLOW_DEV_USER=true
 *   → All /api/v1/* routes work without JWT
 *
 * PROD MODE: Otherwise
 *   → All /api/v1/* routes require valid JWT
 */

import { env, isDevMode, DEV_USER_ID } from './config/env';
import { createApp } from './app';

const app = createApp();

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
