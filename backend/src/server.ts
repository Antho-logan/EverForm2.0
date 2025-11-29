// Express bootstrap for EverForm backend.
import cors from 'cors';
import express, { NextFunction, Request, Response } from 'express';
import { ZodError } from 'zod';
import { env } from './config/env';
import { authMiddleware } from './middleware/auth';
import routes from './routes/index';
import publicCoachRouter from './routes/publicCoach';
import publicScanRouter from './routes/publicScan';

const app = express();

// CORS configuration: relaxed for local mobile development.
// iOS simulator and real devices may use various origins/IPs.
app.use(
  cors({
    origin: true, // Reflect request origin (allows any origin in dev)
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  })
);

app.use(express.json({ limit: '10mb' })); // Increased limit for base64 images

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
app.use('/api/coach', publicCoachRouter);
app.use('/api/scan', publicScanRouter);

// Authenticated routes under /api/v1 (full feature set with auth)
app.use('/api/v1', authMiddleware, routes);

// Centralized error handler keeps responses consistent and avoids leaking internals.
app.use((err: unknown, _req: Request, res: Response, _next: NextFunction) => {
  if (err instanceof ZodError) {
    return res.status(400).json({ message: 'Validation failed', issues: err.issues });
  }

  console.error('Unhandled error', err);
  return res.status(500).json({ message: 'Internal server error' });
});

const port = env.PORT;
app.listen(port, () => {
  console.log(`✓ EverForm backend listening on http://localhost:${port}`);
  console.log(`  Health:     GET  http://localhost:${port}/health`);
  console.log(`  Debug:      GET  http://localhost:${port}/debug/user-test`);
  console.log(`  Coach Chat: POST http://localhost:${port}/api/coach/chat`);
  console.log(`  Food Scan:  POST http://localhost:${port}/api/scan/food`);
});
