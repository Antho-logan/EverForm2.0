/**
 * Sleep Routes
 * Manages sleep logging and retrieval.
 */

import { Router } from 'express';
import { z } from 'zod';
import { AuthenticatedRequest } from '../types';
import { runDailySummary } from '../services/coachAgent';
import { userSelect, userUpsert } from '../utils/db';

const router = Router();

const sleepLogSchema = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  hours: z.number().min(0).max(24),
  sleepScore: z.number().int().min(0).max(100).optional(),
  notes: z.string().optional()
});

/**
 * GET /api/v1/sleep/recent
 */
router.get('/recent', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;
    const limit = parseInt(req.query.limit as string) || 7;

    const { data, error } = await userSelect('sleep_logs', userId, '*')
      .order('date', { ascending: false })
      .limit(limit);

    if (error) {
      console.error('[sleep] Failed to fetch logs:', error.message);
      return res.status(500).json({ message: 'Failed to fetch logs', error: error.message });
    }

    return res.json({ logs: data ?? [], status: 'ok' });
  } catch (err) {
    console.error('[sleep] Unexpected error:', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

/**
 * GET /api/v1/sleep/:date
 */
router.get('/:date', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;
    const { date } = req.params;

    const { data, error } = await userSelect('sleep_logs', userId, '*')
      .eq('date', date)
      .maybeSingle();

    if (error) {
      console.error('[sleep] Failed to fetch log:', error.message);
      return res.status(500).json({ message: 'Failed to fetch log', error: error.message });
    }

    return res.json({ log: data, status: 'ok' });
  } catch (err) {
    console.error('[sleep] Unexpected error:', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

/**
 * POST /api/v1/sleep/log
 * Triggers daily summary recalculation
 */
router.post('/log', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;
    const parsed = sleepLogSchema.parse(req.body);

    const { data, error } = await userUpsert('sleep_logs', userId, {
      date: parsed.date,
      hours: parsed.hours,
      sleep_score: parsed.sleepScore,
      notes: parsed.notes
    }, 'user_id,date').select().single();

    if (error) {
      console.error('[sleep] Failed to create log:', error.message);
      return res.status(500).json({ message: 'Failed to create sleep log', error: error.message });
    }

    runDailySummary(userId, parsed.date).catch(err => {
      console.error('[sleep] Coach agent error:', err);
    });

    return res.status(201).json({ log: data, status: 'ok' });
  } catch (err) {
    if (err instanceof z.ZodError) {
      return res.status(400).json({ message: 'Validation failed', issues: err.issues });
    }
    console.error('[sleep] Unexpected error:', err);
    return res.status(500).json({ message: 'Could not create sleep log' });
  }
});

export default router;
