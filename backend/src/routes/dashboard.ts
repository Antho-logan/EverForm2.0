/**
 * Dashboard Routes
 * Aggregates today's data across all pillars for the main app view.
 */

import { Router } from 'express';
import { supabase } from '../config/supabaseClient';
import { AuthenticatedRequest } from '../types';

const router = Router();

function getTodayDate(timezone?: string): string {
  // Simple UTC date for now; can enhance with timezone later
  return new Date().toISOString().slice(0, 10);
}

/**
 * GET /api/v1/dashboard/today
 * Returns aggregated data for today:
 * - Planned training session
 * - Logged training/nutrition/recovery/sleep
 * - Latest daily summary
 */
router.get('/today', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;
    const date = (req.query.date as string) || getTodayDate();

    // Parallel fetch all today's data
    const [
      trainingSessionResult,
      trainingLogResult,
      nutritionResult,
      recoveryResult,
      sleepResult,
      summaryResult
    ] = await Promise.all([
      // Planned training session for today
      supabase
        .from('training_sessions')
        .select('*, training_exercises(*)')
        .eq('user_id', userId)
        .eq('date_planned', date)
        .maybeSingle(),
      
      // Completed training log for today
      supabase
        .from('training_logs')
        .select('*')
        .eq('user_id', userId)
        .eq('date_performed', date)
        .maybeSingle(),
      
      // Nutrition logs for today
      supabase
        .from('nutrition_logs')
        .select('*')
        .eq('user_id', userId)
        .eq('date', date)
        .order('created_at', { ascending: true }),
      
      // Recovery log for today
      supabase
        .from('recovery_logs')
        .select('*')
        .eq('user_id', userId)
        .eq('date', date)
        .maybeSingle(),
      
      // Sleep log for today (or previous night)
      supabase
        .from('sleep_logs')
        .select('*')
        .eq('user_id', userId)
        .eq('date', date)
        .maybeSingle(),
      
      // Daily summary if exists
      supabase
        .from('daily_summaries')
        .select('*')
        .eq('user_id', userId)
        .eq('date', date)
        .maybeSingle()
    ]);

    // Calculate nutrition totals
    const nutritionLogs = nutritionResult.data ?? [];
    const nutritionTotals = nutritionLogs.reduce(
      (acc, log) => ({
        calories: acc.calories + (log.calories ?? 0),
        protein_g: acc.protein_g + (log.protein_g ?? 0),
        carbs_g: acc.carbs_g + (log.carbs_g ?? 0),
        fat_g: acc.fat_g + (log.fat_g ?? 0)
      }),
      { calories: 0, protein_g: 0, carbs_g: 0, fat_g: 0 }
    );

    // Fetch nutrition targets for comparison
    const { data: nutritionTargets } = await supabase
      .from('nutrition_targets')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();

    return res.json({
      date,
      training: {
        planned: trainingSessionResult.data ?? null,
        logged: trainingLogResult.data ?? null,
        hasPlannedSession: !!trainingSessionResult.data,
        hasCompletedLog: !!trainingLogResult.data
      },
      nutrition: {
        logs: nutritionLogs,
        totals: nutritionTotals,
        targets: nutritionTargets ?? null,
        mealsLogged: nutritionLogs.length
      },
      recovery: {
        log: recoveryResult.data ?? null,
        activities: recoveryResult.data?.activities ?? []
      },
      sleep: {
        log: sleepResult.data ?? null,
        hours: sleepResult.data?.hours ?? null,
        score: sleepResult.data?.sleep_score ?? null
      },
      summary: summaryResult.data ?? null,
      status: 'ok'
    });
  } catch (err) {
    console.error('[dashboard] Error fetching today data:', err);
    return res.json({
      date: getTodayDate(),
      training: { planned: null, logged: null, hasPlannedSession: false, hasCompletedLog: false },
      nutrition: { logs: [], totals: { calories: 0, protein_g: 0, carbs_g: 0, fat_g: 0 }, targets: null, mealsLogged: 0 },
      recovery: { log: null, activities: [] },
      sleep: { log: null, hours: null, score: null },
      summary: null,
      status: 'fallback'
    });
  }
});

/**
 * GET /api/v1/dashboard/week
 * Returns summary data for the past 7 days
 */
router.get('/week', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 6);

    const startStr = startDate.toISOString().slice(0, 10);
    const endStr = endDate.toISOString().slice(0, 10);

    const { data: summaries } = await supabase
      .from('daily_summaries')
      .select('*')
      .eq('user_id', userId)
      .gte('date', startStr)
      .lte('date', endStr)
      .order('date', { ascending: true });

    const { data: latestReport } = await supabase
      .from('weekly_reports')
      .select('*')
      .eq('user_id', userId)
      .order('week_start_date', { ascending: false })
      .limit(1)
      .maybeSingle();

    return res.json({
      startDate: startStr,
      endDate: endStr,
      dailySummaries: summaries ?? [],
      latestReport: latestReport ?? null,
      status: 'ok'
    });
  } catch (err) {
    console.error('[dashboard] Error fetching week data:', err);
    return res.json({
      startDate: '',
      endDate: '',
      dailySummaries: [],
      latestReport: null,
      status: 'fallback'
    });
  }
});

export default router;

