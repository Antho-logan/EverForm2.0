import { supabase } from '../config/supabaseClient';
import { DailyNutritionSummary, MacroSummary } from '../types';
import { getOrCreateDefaultNutritionProfile } from './nutritionProfileService';

function buildMacroSummary(target: number, consumed: number, unit: string): MacroSummary {
  const remaining = Math.max(0, Math.round((target ?? 0) - (consumed ?? 0)));
  return {
    target: Math.round(target ?? 0),
    consumed: Math.round(consumed ?? 0),
    remaining,
    unit,
  };
}

/**
 * Aggregates a single day's nutrition intake and compares it against the user's
 * nutrition profile targets. Currently sums macros from nutrition_logs and
 * nutrition_meals; micronutrients are returned empty until data is available.
 */
export async function getDailyNutritionSummary(userId: string, date: string): Promise<DailyNutritionSummary> {
  const profile = await getOrCreateDefaultNutritionProfile(userId);

  const dayStart = `${date}T00:00:00`;
  const dayEnd = `${date}T23:59:59`;

  const [logsResult, mealsResult] = await Promise.all([
    supabase.from('nutrition_logs').select('*').eq('user_id', userId).eq('date', date),
    supabase.from('nutrition_meals').select('*').eq('user_id', userId).gte('logged_at', dayStart).lte('logged_at', dayEnd),
  ]);

  if (logsResult.error) {
    console.error('[nutritionSummary] Failed to fetch logs', logsResult.error);
    throw new Error('Failed to fetch nutrition logs');
  }
  if (mealsResult.error) {
    console.error('[nutritionSummary] Failed to fetch meals', mealsResult.error);
    throw new Error('Failed to fetch nutrition meals');
  }

  const logs = logsResult.data ?? [];
  const meals = mealsResult.data ?? [];

  const totals = logs.reduce(
    (acc, l) => ({
      kcal: acc.kcal + (l.calories ?? 0),
      protein: acc.protein + (l.protein_g ?? 0),
      carbs: acc.carbs + (l.carbs_g ?? 0),
      fat: acc.fat + (l.fat_g ?? 0),
    }),
    { kcal: 0, protein: 0, carbs: 0, fat: 0 }
  );

  meals.forEach((m: any) => {
    totals.kcal += m.kcal ?? 0;
    totals.protein += m.protein_g ?? 0;
    totals.carbs += m.carbs_g ?? 0;
    totals.fat += m.fat_g ?? 0;
  });

  return {
    date,
    energy: buildMacroSummary(profile.calorieTarget, totals.kcal, 'kcal'),
    protein: buildMacroSummary(profile.proteinTargetG, totals.protein, 'g'),
    carbs: buildMacroSummary(profile.carbTargetG, totals.carbs, 'g'),
    fat: buildMacroSummary(profile.fatTargetG, totals.fat, 'g'),
    micros: [], // placeholder until micronutrient data is available
  };
}





