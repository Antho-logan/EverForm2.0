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

import { Request, Response, NextFunction } from 'express';
import jwt, { JwtPayload } from 'jsonwebtoken';
import { env, isDevMode, DEV_USER_ID } from '../config/env';

// Extend Express.Request
declare module 'express-serve-static-core' {
  interface Request {
    user?: { id: string };
  }
}

/**
 * Main auth middleware for /api/v1/* routes.
 */
export function authMiddleware(req: Request, res: Response, next: NextFunction) {
  // DEV MODE: Auto-attach dev user, skip JWT
  if (isDevMode) {
    req.user = { id: DEV_USER_ID };
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
    const decoded = jwt.verify(token, env.SUPABASE_JWT_SECRET) as JwtPayload;
    const userId = decoded.sub;
    
    if (!userId || typeof userId !== 'string') {
      console.warn('[auth] Token missing subject claim');
      return res.status(401).json({ error: 'Invalid token: missing subject' });
    }
    
    req.user = { id: userId };
    return next();
  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : 'Unknown error';
    console.warn('[auth] JWT verification failed:', errorMessage);
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

/**
 * Optional auth - extracts user if token present, but doesn't require it.
 */
export function optionalAuthMiddleware(req: Request, res: Response, next: NextFunction) {
  if (isDevMode) {
    req.user = { id: DEV_USER_ID };
    return next();
  }

  const authHeader = req.headers['authorization'];
  if (authHeader && authHeader.toLowerCase().startsWith('bearer ')) {
    const token = authHeader.slice('bearer '.length).trim();
    try {
      const decoded = jwt.verify(token, env.SUPABASE_JWT_SECRET) as JwtPayload;
      const userId = decoded.sub;
      if (userId && typeof userId === 'string') {
        req.user = { id: userId };
      }
    } catch {
      // Token invalid but optional - continue without user
    }
  }

  return next();
}
