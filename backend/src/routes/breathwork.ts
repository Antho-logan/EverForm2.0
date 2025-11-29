// Breathwork routes: breathing session logging.
import { Router } from 'express';
import { z } from 'zod';
import { supabase } from '../config/supabaseClient';
import { AuthenticatedRequest } from '../types';

const router = Router();

const breathworkSchema = z.object({
  technique: z.string().min(1),
  durationMinutes: z.number().int().positive().optional(),
  completedAt: z.string().optional()
});

router.get('/sessions', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const { data, error } = await supabase
      .from('breathwork_sessions')
      .select('*')
      .eq('user_id', userId)
      .order('completed_at', { ascending: false })
      .limit(3);

    if (error) {
      console.error('Failed to fetch breathwork sessions', error);
      return res.status(500).json({ message: 'Could not fetch breathwork sessions' });
    }

    return res.json({ breathworkSessions: data ?? [] });
  } catch (err) {
    return next(err);
  }
});

router.post('/sessions', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const parsed = breathworkSchema.parse(req.body);

    const payload = {
      user_id: userId,
      technique: parsed.technique,
      duration_minutes: parsed.durationMinutes,
      completed_at: parsed.completedAt
    };

    const { data, error } = await supabase.from('breathwork_sessions').insert(payload).select().single();

    if (error) {
      console.error('Failed to create breathwork session', error);
      return res.status(500).json({ message: 'Could not create breathwork session' });
    }

    return res.status(201).json({ breathworkSession: data });
  } catch (err) {
    return next(err);
  }
});

export default router;
