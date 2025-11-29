// AI routes: orchestrate DeepSeek plan generation.
import { Router } from 'express';
import { supabase } from '../config/supabaseClient';
import { generatePersonalPlan } from '../services/aiService';
import { AuthenticatedRequest, PillarRecentData, Profile } from '../types';

const router = Router();

router.post('/generate-plan', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;

    const [profileResult, onboardingResult] = await Promise.all([
      supabase.from('profiles').select('*').eq('user_id', userId).maybeSingle(),
      supabase
        .from('onboarding_answers')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
    ]);

    if (profileResult.error) {
      console.error('Failed to fetch profile for AI', profileResult.error);
      return res.status(500).json({ message: 'Could not fetch profile' });
    }

    if (!profileResult.data) {
      return res.status(404).json({ message: 'Profile not found. Please complete onboarding.' });
    }

    if (onboardingResult.error) {
      console.error('Failed to fetch onboarding answers for AI', onboardingResult.error);
      return res.status(500).json({ message: 'Could not fetch onboarding answers' });
    }

    const [training, meals, recovery, mobility, pain, breathwork, lookmax] = await Promise.all([
      supabase
        .from('workout_sessions')
        .select('*')
        .eq('user_id', userId)
        .order('performed_at', { ascending: false })
        .limit(5),
      supabase
        .from('meals')
        .select('*')
        .eq('user_id', userId)
        .order('logged_at', { ascending: false })
        .limit(5),
      supabase
        .from('recovery_logs')
        .select('*')
        .eq('user_id', userId)
        .order('logged_at', { ascending: false })
        .limit(5),
      supabase
        .from('mobility_sessions')
        .select('*, mobility_routines(name, target_areas)')
        .eq('user_id', userId)
        .order('performed_at', { ascending: false })
        .limit(5),
      supabase
        .from('pain_checks')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(5),
      supabase
        .from('breathwork_sessions')
        .select('*')
        .eq('user_id', userId)
        .order('completed_at', { ascending: false })
        .limit(5),
      supabase
        .from('lookmax_sessions')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(5)
    ]);

    const supabaseErrors = [
      training.error,
      meals.error,
      recovery.error,
      mobility.error,
      pain.error,
      breathwork.error,
      lookmax.error
    ].filter(Boolean);

    if (supabaseErrors.length > 0) {
      console.error('Failed to fetch recent data for AI', supabaseErrors);
      return res.status(500).json({ message: 'Could not fetch recent activity' });
    }

    const recentData: PillarRecentData = {
      trainingSessions: training.data ?? [],
      meals: meals.data ?? [],
      recoveryLogs: recovery.data ?? [],
      mobilitySessions: mobility.data ?? [],
      painChecks: pain.data ?? [],
      breathworkSessions: breathwork.data ?? [],
      lookmaxSessions: lookmax.data ?? []
    };

    const plan = await generatePersonalPlan(profileResult.data as Profile, onboardingResult.data ?? [], recentData);

    let storedPlan = null;
    const { error: storeError, data: stored } = await supabase
      .from('ai_plans')
      .insert({
        user_id: userId,
        type: 'full',
        goal: profileResult.data?.primary_goal ?? null,
        payload: plan
      })
      .select()
      .maybeSingle();

    if (storeError) {
      console.warn('Could not persist AI plan to ai_plans', storeError);
    } else {
      storedPlan = stored;
    }

    return res.json({ plan, storedPlan });
  } catch (err) {
    return next(err);
  }
});

export default router;
