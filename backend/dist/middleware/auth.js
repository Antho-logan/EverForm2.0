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
        if (!authHeader || !authHeader.toLowerCase().startsWith('bearer ')) {
            return res.status(401).json({ message: 'Missing Authorization header' });
        }
        const token = authHeader.slice('bearer '.length).trim();
        try {
            const decoded = jsonwebtoken_1.default.verify(token, env_1.env.SUPABASE_JWT_SECRET);
            const userId = decoded.sub;
            if (!userId || typeof userId !== 'string') {
                return res.status(401).json({ message: 'Invalid token: missing subject' });
            }
            // Attach the user id so downstream handlers can enforce user scoping.
            req.user = { id: userId };
            return next();
        }
        catch (err) {
            return res.status(401).json({ message: 'Invalid or expired token' });
        }
    }
    catch (err) {
        return res.status(500).json({ message: 'Authentication failed' });
    }
}
//# sourceMappingURL=auth.js.map