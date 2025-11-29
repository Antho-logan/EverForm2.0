"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.authMiddleware = authMiddleware;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const env_1 = require("../config/env");
function authMiddleware(req, res, next) {
    try {
        const authHeader = req.headers['authorization'];
        if (authHeader && authHeader.toLowerCase().startsWith('bearer ')) {
            const token = authHeader.slice('bearer '.length).trim();
            try {
                const decoded = jsonwebtoken_1.default.verify(token, env_1.env.SUPABASE_JWT_SECRET);
                const userId = decoded.sub;
                if (!userId || typeof userId !== 'string') {
                    return res.status(401).json({ message: 'Invalid token: missing subject' });
                }
                req.user = { id: userId };
                return next();
            }
            catch (err) {
                // Fall through to dev-mode fallback below
                if (process.env.NODE_ENV === 'production') {
                    return res.status(401).json({ message: 'Invalid or expired token' });
                }
                console.warn('[auth] JWT verification failed, using dev fallback user.', err);
            }
        }
        // Dev fallback: allow a fixed user when no/invalid auth and not production
        if (process.env.NODE_ENV !== 'production') {
            req.user = { id: 'dev-user-0001' };
            console.warn('[auth] No Authorization header found. Using dev fallback user_id=dev-user-0001');
            return next();
        }
        return res.status(401).json({ message: 'Missing Authorization header' });
    }
    catch (err) {
        return res.status(500).json({ message: 'Authentication failed' });
    }
}
//# sourceMappingURL=auth.js.map