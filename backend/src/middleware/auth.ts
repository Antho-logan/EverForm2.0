// Auth middleware: verifies Supabase JWT and attaches the authenticated user id to the request.
import { Request, Response, NextFunction } from 'express';
import jwt, { JwtPayload } from 'jsonwebtoken';
import { env } from '../config/env';

// We extend Express.Request to include the authenticated user object.
declare module 'express-serve-static-core' {
  interface Request {
    user?: { id: string };
  }
}

export function authMiddleware(req: Request, res: Response, next: NextFunction) {
  try {
    const authHeader = req.headers['authorization'];

    if (authHeader && authHeader.toLowerCase().startsWith('bearer ')) {
      const token = authHeader.slice('bearer '.length).trim();
      try {
        const decoded = jwt.verify(token, env.SUPABASE_JWT_SECRET) as JwtPayload;
        const userId = decoded.sub;
        if (!userId || typeof userId !== 'string') {
          return res.status(401).json({ message: 'Invalid token: missing subject' });
        }
        req.user = { id: userId };
        return next();
      } catch (err) {
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
  } catch (err) {
    return res.status(500).json({ message: 'Authentication failed' });
  }
}
