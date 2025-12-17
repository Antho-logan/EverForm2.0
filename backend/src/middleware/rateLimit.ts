/**
 * Rate Limiting Middleware
 * 
 * Simple in-memory rate limiter for AI endpoints.
 * Uses user_id if authenticated, falls back to IP address.
 * 
 * NOTE: For production with multiple instances, replace with Redis-backed solution.
 */

import { Request, Response, NextFunction } from 'express';

interface RateLimitEntry {
  count: number;
  resetAt: number;
}

// In-memory store - OK for single instance, replace with Redis for scale
const rateLimitStore = new Map<string, RateLimitEntry>();

// Cleanup old entries every 5 minutes
setInterval(() => {
  const now = Date.now();
  for (const [key, entry] of rateLimitStore.entries()) {
    if (entry.resetAt < now) {
      rateLimitStore.delete(key);
    }
  }
}, 5 * 60 * 1000);

interface RateLimitOptions {
  windowMs: number;      // Time window in milliseconds
  maxRequests: number;   // Max requests per window
  message?: string;      // Custom error message
}

const DEFAULT_OPTIONS: RateLimitOptions = {
  windowMs: 60 * 1000,   // 1 minute
  maxRequests: 20,       // 20 requests per minute
  message: 'Too many requests. Please wait a moment before trying again.',
};

/**
 * Creates a rate limiting middleware.
 * 
 * @param options Rate limit configuration
 * @returns Express middleware
 * 
 * @example
 * // Apply to a specific router
 * router.use(createRateLimiter({ windowMs: 60000, maxRequests: 10 }));
 * 
 * // Or to specific endpoints
 * router.post('/chat', createRateLimiter({ maxRequests: 5 }), chatHandler);
 */
export function createRateLimiter(options: Partial<RateLimitOptions> = {}) {
  const config = { ...DEFAULT_OPTIONS, ...options };

  return (req: Request, res: Response, next: NextFunction) => {
    // Use user_id if authenticated, otherwise fall back to IP
    const userId = (req as any).user?.id;
    const ip = req.ip || req.socket.remoteAddress || 'unknown';
    const identifier = userId ? `user:${userId}` : `ip:${ip}`;

    const now = Date.now();
    let entry = rateLimitStore.get(identifier);

    // Create new entry if doesn't exist or window has passed
    if (!entry || entry.resetAt < now) {
      entry = {
        count: 0,
        resetAt: now + config.windowMs,
      };
      rateLimitStore.set(identifier, entry);
    }

    entry.count++;

    // Set rate limit headers
    res.setHeader('X-RateLimit-Limit', config.maxRequests);
    res.setHeader('X-RateLimit-Remaining', Math.max(0, config.maxRequests - entry.count));
    res.setHeader('X-RateLimit-Reset', Math.ceil(entry.resetAt / 1000));

    if (entry.count > config.maxRequests) {
      const retryAfter = Math.ceil((entry.resetAt - now) / 1000);
      res.setHeader('Retry-After', retryAfter);

      console.warn(`[rateLimit] Rate limit exceeded for ${identifier}`);

      return res.status(429).json({
        error: 'rate_limit_exceeded',
        message: config.message,
        retryAfter,
      });
    }

    return next();
  };
}

/**
 * Pre-configured rate limiter for AI chat endpoints.
 * 20 requests per minute per user/IP.
 */
export const aiChatLimiter = createRateLimiter({
  windowMs: 60 * 1000,
  maxRequests: 20,
  message: 'Too many AI requests. Please wait a moment before trying again.',
});

/**
 * Pre-configured rate limiter for scan endpoints.
 * 10 requests per minute (more expensive operation).
 */
export const scanLimiter = createRateLimiter({
  windowMs: 60 * 1000,
  maxRequests: 10,
  message: 'Too many scan requests. Please wait before scanning again.',
});

// TODO: Add per-user quota tracking for premium features
// interface UserQuota {
//   dailyLimit: number;
//   usedToday: number;
//   resetDate: string;
// }
// export async function checkUserQuota(userId: string): Promise<boolean> { ... }












