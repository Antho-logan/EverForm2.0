// Recovery routes: sleep/stress logging.
import { Router } from 'express';
import { z } from 'zod';
import { supabase } from '../config/supabaseClient';
import { AuthenticatedRequest } from '../types';

const router = Router();

const recoverySchema = z.object({
  sleepHours: z.number().nonnegative().optional(),
  sleepScore: z.number().int().min(0).max(100).optional(),
  stressLevel: z.number().int().min(1).max(10).optional(),
  notes: z.string().optional(),
  loggedAt: z.string()
});

router.get('/recent', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const { data: recoveryLogs, error } = await supabase
      .from('recovery_logs')
      .select('*')
      .eq('user_id', userId)
      .order('logged_at', { ascending: false })
      .limit(1);

    const { data: painChecks, error: painError } = await supabase
      .from('pain_checks')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(1);

    if (error || painError) {
      console.error('Failed to fetch recovery logs', error || painError);
      return res.status(500).json({ message: 'Could not fetch recovery data' });
    }

    return res.json({
      recoveryLog: recoveryLogs?.[0] ?? null,
      recentPainCheck: painChecks?.[0] ?? null
    });
  } catch (err) {
    return next(err);
  }
});

router.post('/log', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const parsed = recoverySchema.parse(req.body);

    const payload = {
      user_id: userId,
      sleep_hours: parsed.sleepHours,
      sleep_score: parsed.sleepScore,
      stress_level: parsed.stressLevel,
      notes: parsed.notes,
      logged_at: parsed.loggedAt
    };

    const { data, error } = await supabase.from('recovery_logs').insert(payload).select().single();

    if (error) {
      console.error('Failed to create recovery log', error);
      return res.status(500).json({ message: 'Could not create recovery log' });
    }

    return res.status(201).json({ recoveryLog: data });
  } catch (err) {
    return next(err);
  }
});

export default router;
