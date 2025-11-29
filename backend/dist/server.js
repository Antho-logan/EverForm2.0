"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
// Express bootstrap for EverForm backend.
const cors_1 = __importDefault(require("cors"));
const express_1 = __importDefault(require("express"));
const zod_1 = require("zod");
const env_1 = require("./config/env");
const auth_1 = require("./middleware/auth");
const index_1 = __importDefault(require("./routes/index"));
const publicCoach_1 = __importDefault(require("./routes/publicCoach"));
const publicScan_1 = __importDefault(require("./routes/publicScan"));
const app = (0, express_1.default)();
// CORS configuration: relaxed for local mobile development.
// iOS simulator and real devices may use various origins/IPs.
app.use((0, cors_1.default)({
    origin: true, // Reflect request origin (allows any origin in dev)
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
}));
app.use(express_1.default.json({ limit: '10mb' })); // Increased limit for base64 images
// Health check endpoint
app.get('/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
// Debug endpoint for connectivity testing (no DB hit)
app.get('/debug/user-test', (_req, res) => {
    res.json({ ok: true, message: 'Backend is reachable' });
});
// Public API routes (no auth required for local dev)
// These simplified endpoints are designed for the iOS app
app.use('/api/coach', publicCoach_1.default);
app.use('/api/scan', publicScan_1.default);
// Authenticated routes under /api/v1 (full feature set with auth)
app.use('/api/v1', auth_1.authMiddleware, index_1.default);
// Centralized error handler keeps responses consistent and avoids leaking internals.
app.use((err, _req, res, _next) => {
    if (err instanceof zod_1.ZodError) {
        return res.status(400).json({ message: 'Validation failed', issues: err.issues });
    }
    console.error('Unhandled error', err);
    return res.status(500).json({ message: 'Internal server error' });
});
const port = env_1.env.PORT;
app.listen(port, () => {
    console.log(`✓ EverForm backend listening on http://localhost:${port}`);
    console.log(`  Health:     GET  http://localhost:${port}/health`);
    console.log(`  Debug:      GET  http://localhost:${port}/debug/user-test`);
    console.log(`  Coach Chat: POST http://localhost:${port}/api/coach/chat`);
    console.log(`  Food Scan:  POST http://localhost:${port}/api/scan/food`);
});
//# sourceMappingURL=server.js.map