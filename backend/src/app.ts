/**
 * Express App Factory
 *
 * Exports the configured Express app without starting a listener.
 * This enables:
 * - unit/integration tests (Supertest)
 * - reuse in jobs / serverless adapters
 * - cleaner separation of concerns (app vs process)
 */

import cors from 'cors';
import express, { NextFunction, Request, Response } from 'express';
import { ZodError } from 'zod';

import { isDevMode } from './config/env';
import { authMiddleware } from './middleware/auth';
import routes from './routes/index';
import coachRouter from './routes/publicCoach';
import scanRouter from './routes/publicScan';

export function createApp() {
  const app = express();

  // ─────────────────────────────────────────────────────────────────────────────
  // MIDDLEWARE
  // ─────────────────────────────────────────────────────────────────────────────

  app.use(cors({ origin: true, credentials: true }));
  app.use(express.json({ limit: '10mb' }));

  // ─────────────────────────────────────────────────────────────────────────────
  // PUBLIC HEALTH ENDPOINT (no auth)
  // ─────────────────────────────────────────────────────────────────────────────

  app.get('/health', (_req, res) => {
    res.json({
      status: 'ok',
      timestamp: new Date().toISOString(),
      version: '2.0.0',
      mode: isDevMode ? 'development' : 'production',
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // AI ENDPOINTS (auth + rate limited)
  // /api/coach/chat, /api/scan/food, /api/scan/test
  // ─────────────────────────────────────────────────────────────────────────────

  app.use('/api/coach', coachRouter);
  app.use('/api/scan', scanRouter);

  // ─────────────────────────────────────────────────────────────────────────────
  // AUTHENTICATED ROUTES under /api/v1
  // All routes here go through authMiddleware
  // ─────────────────────────────────────────────────────────────────────────────

  app.use('/api/v1', authMiddleware, routes);

  // ─────────────────────────────────────────────────────────────────────────────
  // ERROR HANDLER
  // ─────────────────────────────────────────────────────────────────────────────

  app.use((err: unknown, _req: Request, res: Response, _next: NextFunction) => {
    if (err instanceof ZodError) {
      return res.status(400).json({
        error: 'Validation failed',
        issues: err.issues,
      });
    }

    console.error('[server] Unhandled error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  });

  return app;
}

