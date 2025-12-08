/**
 * Fix Pain Routes
 * Pain checks logging and retrieval.
 */

import { Router } from 'express';
import { z } from 'zod';
import { AuthenticatedRequest } from '../types';
import { userSelect, userInsert } from '../utils/db';

const router = Router();

const painCheckSchema = z.object({
  area: z.string().min(1),
  severity: z.number().int().min(1).max(10),
  description: z.string().optional()
});

/**
 * GET /api/v1/fix-pain/recent
 */
router.get('/recent', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;

    const { data, error } = await userSelect('pain_checks', userId, '*')
      .order('created_at', { ascending: false })
      .limit(3);

    if (error) {
      console.error('[fixPain] Failed to fetch pain checks:', error.message);
      return res.status(500).json({ 
        message: 'Failed to fetch pain checks',
        error: error.message 
      });
    }

    return res.json({ painChecks: data ?? [], status: 'ok' });
  } catch (err) {
    console.error('[fixPain] Unexpected error in recent:', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

/**
 * POST /api/v1/fix-pain/assess
 */
router.post('/assess', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;
    const parsed = painCheckSchema.parse(req.body);

    const { data, error } = await userInsert('pain_checks', userId, {
      area: parsed.area,
      severity: parsed.severity,
      description: parsed.description
    }).select().single();

    if (error) {
      console.error('[fixPain] Failed to create pain check:', error.message);
      return res.status(500).json({ 
        message: 'Failed to create pain check',
        error: error.message 
      });
    }

    return res.status(201).json({ painCheck: data, status: 'ok' });
  } catch (err) {
    if (err instanceof z.ZodError) {
      return res.status(400).json({ message: 'Validation failed', issues: err.issues });
    }
    console.error('[fixPain] Unexpected error on create:', err);
    return res.status(500).json({ message: 'Could not create pain check' });
  }
});

export default router;
