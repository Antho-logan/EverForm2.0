"use strict";
/**
 * Auth Middleware
 *
 * Verifies JWT and attaches user id to request.
 *
 * BEHAVIOR:
 * - DEV MODE (isDevMode=true):
 *   → All requests get req.user = { id: DEV_USER_ID }
 *   → No JWT required
 *   → iOS app "just works" without auth
 *
 * - PROD MODE (isDevMode=false):
 *   → Requires valid JWT in Authorization: Bearer <token>
 *   → Returns 401 for missing/invalid tokens
 *   → No hidden fallbacks
 */
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.authMiddleware = authMiddleware;
exports.optionalAuthMiddleware = optionalAuthMiddleware;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const env_1 = require("../config/env");
/**
 * Main auth middleware for /api/v1/* routes.
 */
function authMiddleware(req, res, next) {
    // DEV MODE: Auto-attach dev user, skip JWT
    if (env_1.isDevMode) {
        req.user = { id: env_1.DEV_USER_ID };
        return next();
    }
    // PROD MODE: Require valid JWT
    const authHeader = req.headers['authorization'];
    if (!authHeader || !authHeader.toLowerCase().startsWith('bearer ')) {
        return res.status(401).json({
            error: 'Authentication required',
            hint: 'Include Authorization: Bearer <token> header'
        });
    }
    const token = authHeader.slice('bearer '.length).trim();
    try {
        const decoded = jsonwebtoken_1.default.verify(token, env_1.env.SUPABASE_JWT_SECRET);
        const userId = decoded.sub;
        if (!userId || typeof userId !== 'string') {
            console.warn('[auth] Token missing subject claim');
            return res.status(401).json({ error: 'Invalid token: missing subject' });
        }
        req.user = { id: userId };
        return next();
    }
    catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'Unknown error';
        console.warn('[auth] JWT verification failed:', errorMessage);
        return res.status(401).json({ error: 'Invalid or expired token' });
    }
}
/**
 * Optional auth - extracts user if token present, but doesn't require it.
 */
function optionalAuthMiddleware(req, res, next) {
    if (env_1.isDevMode) {
        req.user = { id: env_1.DEV_USER_ID };
        return next();
    }
    const authHeader = req.headers['authorization'];
    if (authHeader && authHeader.toLowerCase().startsWith('bearer ')) {
        const token = authHeader.slice('bearer '.length).trim();
        try {
            const decoded = jsonwebtoken_1.default.verify(token, env_1.env.SUPABASE_JWT_SECRET);
            const userId = decoded.sub;
            if (userId && typeof userId === 'string') {
                req.user = { id: userId };
            }
        }
        catch {
            // Token invalid but optional - continue without user
        }
    }
    return next();
}
//# sourceMappingURL=auth.js.map