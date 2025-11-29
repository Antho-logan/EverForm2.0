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
const app = (0, express_1.default)();
app.use((0, cors_1.default)());
app.use(express_1.default.json());
app.get('/health', (_req, res) => {
    res.json({ status: 'ok' });
});
// All application routes require a valid Supabase JWT via authMiddleware.
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
    console.log(`EverForm backend listening on port ${port}`);
});
//# sourceMappingURL=server.js.map