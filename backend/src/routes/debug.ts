/**
 * Debug Routes
 * 
 * Auth-protected endpoints for debugging environment and configuration.
 * Never exposes actual secret values - only lengths and presence.
 */

import { Router } from 'express';
import { env } from '../config/env';
import { AuthenticatedRequest } from '../types';

const router = Router();

/**
 * GET /api/v1/debug/env
 * 
 * Returns presence/length of critical environment variables.
 * Auth-protected so only authenticated users can access.
 */
router.get('/env', async (req: AuthenticatedRequest, res) => {
  const userId = req.user?.id;
  
  // Log access for audit
  console.log(`[debug] /env accessed by user: ${userId?.slice(0, 8)}...`);

  return res.json({
    timestamp: new Date().toISOString(),
    environment: {
      NODE_ENV: process.env.NODE_ENV || '(not set)',
      ALLOW_DEV_USER: process.env.ALLOW_DEV_USER || '(not set)',
    },
    keys: {
      SUPABASE_URL: {
        present: !!env.SUPABASE_URL,
        length: env.SUPABASE_URL?.length ?? 0,
      },
      SUPABASE_SERVICE_ROLE_KEY: {
        present: !!env.SUPABASE_SERVICE_ROLE_KEY,
        length: env.SUPABASE_SERVICE_ROLE_KEY?.length ?? 0,
      },
      SUPABASE_JWT_SECRET: {
        present: !!env.SUPABASE_JWT_SECRET,
        length: env.SUPABASE_JWT_SECRET?.length ?? 0,
      },
      DEEPSEEK_API_KEY: {
        present: !!env.DEEPSEEK_API_KEY,
        length: env.DEEPSEEK_API_KEY?.length ?? 0,
      },
      SCAN_API_KEY: {
        present: !!env.SCAN_API_KEY && env.SCAN_API_KEY.trim() !== '',
        length: env.SCAN_API_KEY?.length ?? 0,
        note: env.SCAN_API_KEY?.trim() === '' ? 'empty (will use mock)' : 'configured',
      },
      SCAN_API_URL: {
        present: !!env.SCAN_API_URL,
        value: env.SCAN_API_URL, // URL is not secret
      },
    },
    status: 'ok',
  });
});

/**
 * GET /api/v1/debug/health
 * 
 * Extended health check with service connectivity status.
 */
router.get('/health', async (req: AuthenticatedRequest, res) => {
  const checks = {
    env: {
      supabase: !!env.SUPABASE_URL && !!env.SUPABASE_SERVICE_ROLE_KEY,
      deepseek: !!env.DEEPSEEK_API_KEY,
      scan: !!env.SCAN_API_KEY && env.SCAN_API_KEY.trim() !== '',
    },
  };

  const allOk = checks.env.supabase && checks.env.deepseek;

  return res.json({
    status: allOk ? 'ok' : 'degraded',
    timestamp: new Date().toISOString(),
    checks,
    warnings: [
      ...(!checks.env.scan ? ['SCAN_API_KEY not configured - food scanning uses mock data'] : []),
    ],
  });
});

export default router;








