// Look Max routes: track aesthetic improvement sessions.
import { Router } from 'express';
import { z } from 'zod';
import { supabase } from '../config/supabaseClient';
import { AuthenticatedRequest } from '../types';

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

router.get('/routines', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const { data, error } = await supabase
      .from('lookmax_sessions')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(3);

    if (error) {
      console.error('Failed to fetch lookmax sessions', error);
      return res.status(500).json({ message: 'Could not fetch lookmax sessions' });
    }

    return res.json({ lookmaxSessions: data ?? [] });
  } catch (err) {
    return next(err);
  }
});

router.post('/routines', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const parsed = lookmaxRoutineSchema.parse(req.body);

    const payload = {
      user_id: userId,
      category: parsed.category,
      plan_json: parsed.planJson,
      notes: parsed.notes
    };

    const { data, error } = await supabase.from('lookmax_sessions').insert(payload).select().single();

    if (error) {
      console.error('Failed to create lookmax session', error);
      return res.status(500).json({ message: 'Could not create lookmax session' });
    }

    return res.status(201).json({ lookmaxSession: data });
  } catch (err) {
    return next(err);
  }
});

router.post('/actions', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const parsed = lookmaxActionSchema.parse(req.body);

    const payload = {
      user_id: userId,
      session_id: parsed.routineId,
      action: parsed.action,
      notes: parsed.notes
    };

    const { data, error } = await supabase.from('lookmax_actions').insert(payload).select().single();

    if (error) {
      console.error('Failed to create lookmax action', error);
      return res.status(500).json({ message: 'Could not create lookmax action' });
    }

    return res.status(201).json({ action: data });
  } catch (err) {
    return next(err);
  }
});

export default router;
