// Fix Pain routes: pain checks logging.
import { Router } from 'express';
import { z } from 'zod';
import { supabase } from '../config/supabaseClient';
import { AuthenticatedRequest } from '../types';

const router = Router();

const painCheckSchema = z.object({
  area: z.string().min(1),
  severity: z.number().int().min(1).max(10),
  description: z.string().optional()
});

router.get('/recent', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const { data, error } = await supabase
      .from('pain_checks')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(3);

    if (error) {
      console.error('Failed to fetch pain checks', error);
      return res.status(500).json({ message: 'Could not fetch pain checks' });
    }

    return res.json({ painChecks: data ?? [] });
  } catch (err) {
    return next(err);
  }
});

router.post('/assess', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const parsed = painCheckSchema.parse(req.body);

    const payload = {
      user_id: userId,
      area: parsed.area,
      severity: parsed.severity,
      description: parsed.description
    };

    const { data, error } = await supabase.from('pain_checks').insert(payload).select().single();

    if (error) {
      console.error('Failed to create pain check', error);
      return res.status(500).json({ message: 'Could not create pain check' });
    }

    return res.status(201).json({ painCheck: data });
  } catch (err) {
    return next(err);
  }
});

export default router;
