// Express bootstrap for EverForm backend.
import cors from 'cors';
import express, { NextFunction, Request, Response } from 'express';
import { ZodError } from 'zod';
import { env } from './config/env';
import { authMiddleware } from './middleware/auth';
import routes from './routes/index';

const app = express();

app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

// All application routes require a valid Supabase JWT via authMiddleware.
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
  console.log(`EverForm backend listening on port ${port}`);
});
