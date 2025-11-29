// Mobility routes: routines and session logging.
import { Router } from 'express';
import { z } from 'zod';
import { supabase } from '../config/supabaseClient';
import { AuthenticatedRequest } from '../types';

const router = Router();

const mobilitySessionSchema = z.object({
  routineId: z.string(),
  status: z.enum(['completed', 'skipped']).default('completed'),
  performedAt: z.string().optional()
});

router.get('/plan', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const { data, error } = await supabase
      .from('mobility_plans')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) {
      console.error('Failed to fetch mobility plan', error);
      return res.status(500).json({ message: 'Could not fetch mobility plan' });
    }

    return res.json({ plan: data ?? null });
  } catch (err) {
    return next(err);
  }
});

router.get('/sessions', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const { data, error } = await supabase
      .from('mobility_sessions')
      .select('*, mobility_routines(name, duration_minutes)')
      .eq('user_id', userId)
      .order('performed_at', { ascending: false })
      .limit(3);

    if (error) {
      console.error('Failed to fetch mobility sessions', error);
      return res.status(500).json({ message: 'Could not fetch mobility sessions' });
    }

    return res.json({ mobilitySessions: data ?? [] });
  } catch (err) {
    return next(err);
  }
});

router.post('/sessions', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const parsed = mobilitySessionSchema.parse(req.body);

    const payload = {
      user_id: userId,
      routine_id: parsed.routineId,
      status: parsed.status,
      performed_at: parsed.performedAt
    };

    const { data, error } = await supabase.from('mobility_sessions').insert(payload).select().single();

    if (error) {
      console.error('Failed to create mobility session', error);
      return res.status(500).json({ message: 'Could not create mobility session' });
    }

    return res.status(201).json({ mobilitySession: data });
  } catch (err) {
    return next(err);
  }
});

export default router;
