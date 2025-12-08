/**
 * Goals Routes
 * Manages user fitness goals and preferences.
 */

import { Router } from 'express';
import { z } from 'zod';
import { AuthenticatedRequest } from '../types';
import { onGoalChanged } from '../services/coachAgent';
import { userSelect, userUpsert } from '../utils/db';

const router = Router();

const goalsSchema = z.object({
  primaryGoal: z.enum(['muscle_gain', 'fat_loss', 'performance', 'health']).optional(),
  secondaryGoals: z.array(z.string()).optional(),
  preferredTrainingDays: z.array(z.string()).optional(),
  sessionLengthMinutes: z.number().int().min(15).max(180).optional(),
  equipmentAccess: z.string().optional()
});

/**
 * GET /api/v1/goals
 */
router.get('/', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;

    const { data, error } = await userSelect('goals', userId, '*').maybeSingle();

    if (error) {
      console.error('[goals] Failed to fetch goals:', error.message);
      return res.status(500).json({ message: 'Failed to fetch goals', error: error.message });
    }

    return res.json({ goals: data, status: 'ok' });
  } catch (err) {
    console.error('[goals] Unexpected error:', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

/**
 * POST /api/v1/goals
 * Triggers coach agent to update training plan
 */
router.post('/', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;
    const parsed = goalsSchema.parse(req.body);

    const { data, error } = await userUpsert('goals', userId, {
      primary_goal: parsed.primaryGoal,
      secondary_goals: parsed.secondaryGoals ?? [],
      preferred_training_days: parsed.preferredTrainingDays ?? [],
      session_length_minutes: parsed.sessionLengthMinutes ?? 60,
      equipment_access: parsed.equipmentAccess ?? 'full_gym',
      updated_at: new Date().toISOString()
    }).select().single();

    if (error) {
      console.error('[goals] Failed to upsert goals:', error.message);
      return res.status(500).json({ message: 'Failed to save goals', error: error.message });
    }

    // Trigger coach agent (fire and forget)
    onGoalChanged(userId).catch(err => {
      console.error('[goals] Coach agent error:', err);
    });

    return res.status(201).json({ goals: data, status: 'ok' });
  } catch (err) {
    if (err instanceof z.ZodError) {
      return res.status(400).json({ message: 'Validation failed', issues: err.issues });
    }
    console.error('[goals] Unexpected error:', err);
    return res.status(500).json({ message: 'Could not save goals' });
  }
});

export default router;
