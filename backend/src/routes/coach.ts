import { Router } from 'express';
import { z } from 'zod';
import { generateCoachReply } from '../services/aiService';
import { supabase } from '../config/supabaseClient';
import { AuthenticatedRequest } from '../types';

const router = Router();

const messageSchema = z.object({
  message: z.string().min(1),
  context: z.record(z.any()).optional()
});

router.post('/message', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const parseResult = messageSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({ error: 'Invalid payload' });
    }
    const { message, context: clientContext } = parseResult.data;

    // Gather rich context from DB
    const { data: profile } = await supabase.from('profiles').select('*').eq('user_id', userId).maybeSingle();
    const { data: recentMeals } = await supabase
      .from('nutrition_meals')
      .select('*')
      .eq('user_id', userId)
      .order('logged_at', { ascending: false })
      .limit(3);

    const fullContext = {
      ...clientContext,
      profile,
      recentMeals: recentMeals ?? undefined
    };

    const reply = await generateCoachReply(message, fullContext);

    return res.json({ reply });
  } catch (err) {
    return next(err);
  }
});

export default router;
