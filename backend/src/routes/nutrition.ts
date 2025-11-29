// Nutrition routes: meals and daily summaries.
import { Router } from 'express';
import { z } from 'zod';
import { supabase } from '../config/supabaseClient';
import { AuthenticatedRequest, Meal } from '../types';

const router = Router();

const mealSchema = z.object({
  mealType: z.enum(['breakfast', 'lunch', 'dinner', 'snack']),
  title: z.string().min(1),
  kcal: z.number().int().nonnegative().optional(),
  proteinG: z.number().nonnegative().optional(),
  carbsG: z.number().nonnegative().optional(),
  fatG: z.number().nonnegative().optional(),
  loggedAt: z.string(),
  source: z.string().optional()
});

router.get('/summary', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const date = (req.query.date as string) || new Date().toISOString().slice(0, 10);
    const start = new Date(date);
    start.setHours(0, 0, 0, 0);
    const end = new Date(start);
    end.setHours(23, 59, 59, 999);

    const { data, error } = await supabase
      .from('nutrition_meals')
      .select('*')
      .eq('user_id', userId)
      .gte('logged_at', start.toISOString())
      .lte('logged_at', end.toISOString())
      .order('logged_at', { ascending: false });

    if (error) {
      console.error('Failed to fetch meals summary', error);
      return res.status(500).json({ message: 'Could not fetch meals summary' });
    }

    const meals: Meal[] = data ?? [];
    const totals = meals.reduce(
      (acc, meal) => {
        acc.kcal += meal.kcal ?? 0;
        acc.protein += meal.protein_g ?? 0;
        acc.carbs += meal.carbs_g ?? 0;
        acc.fat += meal.fat_g ?? 0;
        return acc;
      },
      { kcal: 0, protein: 0, carbs: 0, fat: 0 }
    );

    return res.json({ date, totals, meals });
  } catch (err) {
    return next(err);
  }
});

router.get('/meals', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const date = (req.query.date as string) || new Date().toISOString().slice(0, 10);
    const start = new Date(date);
    start.setHours(0, 0, 0, 0);
    const end = new Date(start);
    end.setHours(23, 59, 59, 999);

    const { data, error } = await supabase
      .from('nutrition_meals')
      .select('*')
      .eq('user_id', userId)
      .gte('logged_at', start.toISOString())
      .lte('logged_at', end.toISOString())
      .order('logged_at', { ascending: false });

    if (error) {
      console.error('Failed to fetch meals', error);
      return res.status(500).json({ message: 'Could not fetch meals' });
    }

    const meals: Meal[] = data ?? [];
    return res.json({ meals });
  } catch (err) {
    return next(err);
  }
});

router.post('/meals', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const parsed = mealSchema.parse(req.body);

    const payload = {
      user_id: userId,
      meal_type: parsed.mealType,
      title: parsed.title,
      kcal: parsed.kcal,
      protein_g: parsed.proteinG,
      carbs_g: parsed.carbsG,
      fat_g: parsed.fatG,
      logged_at: parsed.loggedAt,
      source: parsed.source
    };

    const { data, error } = await supabase.from('nutrition_meals').insert(payload).select().single();

    if (error) {
      console.error('Failed to create meal', error);
      return res.status(500).json({ message: 'Could not create meal' });
    }

    return res.status(201).json({ meal: data });
  } catch (err) {
    return next(err);
  }
});

export default router;
