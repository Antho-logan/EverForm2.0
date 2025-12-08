/**
 * Look Max Routes
 * Track aesthetic improvement sessions.
 */

import { Router } from 'express';
import { z } from 'zod';
import { AuthenticatedRequest } from '../types';
import { userSelect, userInsert } from '../utils/db';

const router = Router();

const lookmaxRoutineSchema = z.object({
  category: z.enum(['hair', 'jawline', 'skin', 'posture', 'style']),
  planJson: z.record(z.any()).optional(),
  notes: z.string().optional()
});

const lookmaxActionSchema = z.object({
  routineId: z.string(),
  action: z.string(),
  notes: z.string().optional()
});

/**
 * GET /api/v1/lookmax/routines
 */
router.get('/routines', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;
    
    const { data, error } = await userSelect('lookmax_sessions', userId, '*')
      .order('created_at', { ascending: false })
      .limit(3);

    if (error) {
      console.error('[lookmax] Failed to fetch sessions:', error.message);
      return res.status(500).json({ message: 'Could not fetch lookmax sessions', error: error.message });
    }

    return res.json({ lookmaxSessions: data ?? [], status: 'ok' });
  } catch (err) {
    console.error('[lookmax] Unexpected error:', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

/**
 * POST /api/v1/lookmax/routines
 */
router.post('/routines', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;
    const parsed = lookmaxRoutineSchema.parse(req.body);

    const { data, error } = await userInsert('lookmax_sessions', userId, {
      category: parsed.category,
      plan_json: parsed.planJson,
      notes: parsed.notes
    }).select().single();

    if (error) {
      console.error('[lookmax] Failed to create session:', error.message);
      return res.status(500).json({ message: 'Could not create lookmax session', error: error.message });
    }

    return res.status(201).json({ lookmaxSession: data, status: 'ok' });
  } catch (err) {
    if (err instanceof z.ZodError) {
      return res.status(400).json({ message: 'Validation failed', issues: err.issues });
    }
    console.error('[lookmax] Unexpected error:', err);
    return res.status(500).json({ message: 'Could not create lookmax session' });
  }
});

/**
 * POST /api/v1/lookmax/actions
 */
router.post('/actions', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;
    const parsed = lookmaxActionSchema.parse(req.body);

    const { data, error } = await userInsert('lookmax_actions', userId, {
      session_id: parsed.routineId,
      action: parsed.action,
      notes: parsed.notes
    }).select().single();

    if (error) {
      console.error('[lookmax] Failed to create action:', error.message);
      return res.status(500).json({ message: 'Could not create lookmax action', error: error.message });
    }

    return res.status(201).json({ action: data, status: 'ok' });
  } catch (err) {
    if (err instanceof z.ZodError) {
      return res.status(400).json({ message: 'Validation failed', issues: err.issues });
    }
    console.error('[lookmax] Unexpected error:', err);
    return res.status(500).json({ message: 'Could not create lookmax action' });
  }
});

export default router;
