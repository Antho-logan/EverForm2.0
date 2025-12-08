"use strict";
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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const cors_1 = __importDefault(require("cors"));
const express_1 = __importDefault(require("express"));
const zod_1 = require("zod");
const env_1 = require("./config/env");
const auth_1 = require("./middleware/auth");
const index_1 = __importDefault(require("./routes/index"));
const publicCoach_1 = __importDefault(require("./routes/publicCoach"));
const publicScan_1 = __importDefault(require("./routes/publicScan"));
const app = (0, express_1.default)();
// ─────────────────────────────────────────────────────────────────────────────
// MIDDLEWARE
// ─────────────────────────────────────────────────────────────────────────────
app.use((0, cors_1.default)({ origin: true, credentials: true }));
app.use(express_1.default.json({ limit: '10mb' }));
// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC HEALTH ENDPOINT (no auth)
// ─────────────────────────────────────────────────────────────────────────────
app.get('/health', (_req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        version: '2.0.0',
        mode: env_1.isDevMode ? 'development' : 'production'
    });
});
// ─────────────────────────────────────────────────────────────────────────────
// AI ENDPOINTS (auth + rate limited)
// /api/coach/chat, /api/scan/food, /api/scan/test
// ─────────────────────────────────────────────────────────────────────────────
app.use('/api/coach', publicCoach_1.default);
app.use('/api/scan', publicScan_1.default);
// ─────────────────────────────────────────────────────────────────────────────
// AUTHENTICATED ROUTES under /api/v1
// All routes here go through authMiddleware
// ─────────────────────────────────────────────────────────────────────────────
app.use('/api/v1', auth_1.authMiddleware, index_1.default);
// ─────────────────────────────────────────────────────────────────────────────
// ERROR HANDLER
// ─────────────────────────────────────────────────────────────────────────────
app.use((err, _req, res, _next) => {
    if (err instanceof zod_1.ZodError) {
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
const port = env_1.env.PORT;
app.listen(port, () => {
    console.log('');
    console.log('╔═══════════════════════════════════════════════════════════╗');
    console.log('║           EverForm Backend v2.0.0                         ║');
    console.log('╠═══════════════════════════════════════════════════════════╣');
    console.log(`║  🌐 Server:      http://localhost:${port}                     ║`);
    console.log(`║  📦 NODE_ENV:    ${env_1.env.NODE_ENV.padEnd(39)}║`);
    if (env_1.isDevMode) {
        console.log('║  🔓 Auth Mode:   DEV (no JWT required)                     ║');
        console.log(`║  👤 Dev User:    ${env_1.DEV_USER_ID.padEnd(39)}║`);
    }
    else {
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
    if (env_1.isDevMode) {
        console.log('  ✅ iOS app can call /api/v1/* without auth token');
        console.log('');
    }
});
//# sourceMappingURL=server.js.map