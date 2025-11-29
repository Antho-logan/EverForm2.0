"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// AI routes: orchestrate DeepSeek plan generation.
const express_1 = require("express");
const supabaseClient_1 = require("../config/supabaseClient");
const aiService_1 = require("../services/aiService");
const router = (0, express_1.Router)();
router.post('/generate-plan', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const [profileResult, onboardingResult] = await Promise.all([
            supabaseClient_1.supabase.from('profiles').select('*').eq('user_id', userId).maybeSingle(),
            supabaseClient_1.supabase
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
            supabaseClient_1.supabase
                .from('workout_sessions')
                .select('*')
                .eq('user_id', userId)
                .order('performed_at', { ascending: false })
                .limit(5),
            supabaseClient_1.supabase
                .from('meals')
                .select('*')
                .eq('user_id', userId)
                .order('logged_at', { ascending: false })
                .limit(5),
            supabaseClient_1.supabase
                .from('recovery_logs')
                .select('*')
                .eq('user_id', userId)
                .order('logged_at', { ascending: false })
                .limit(5),
            supabaseClient_1.supabase
                .from('mobility_sessions')
                .select('*, mobility_routines(name, target_areas)')
                .eq('user_id', userId)
                .order('performed_at', { ascending: false })
                .limit(5),
            supabaseClient_1.supabase
                .from('pain_checks')
                .select('*')
                .eq('user_id', userId)
                .order('created_at', { ascending: false })
                .limit(5),
            supabaseClient_1.supabase
                .from('breathwork_sessions')
                .select('*')
                .eq('user_id', userId)
                .order('completed_at', { ascending: false })
                .limit(5),
            supabaseClient_1.supabase
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
        const recentData = {
            trainingSessions: training.data ?? [],
            meals: meals.data ?? [],
            recoveryLogs: recovery.data ?? [],
            mobilitySessions: mobility.data ?? [],
            painChecks: pain.data ?? [],
            breathworkSessions: breathwork.data ?? [],
            lookmaxSessions: lookmax.data ?? []
        };
        const plan = await (0, aiService_1.generatePersonalPlan)(profileResult.data, onboardingResult.data ?? [], recentData);
        let storedPlan = null;
        const { error: storeError, data: stored } = await supabaseClient_1.supabase
            .from('workout_plans')
            .insert({
            user_id: userId,
            name: 'AI Personalized Plan',
            goal: profileResult.data?.primary_goal ?? null,
            weeks: 12,
            plan_json: plan
        })
            .select()
            .maybeSingle();
        if (storeError) {
            console.warn('Could not persist AI plan to workout_plans', storeError);
        }
        else {
            storedPlan = stored;
        }
        return res.json({ plan, storedPlan });
    }
    catch (err) {
        return next(err);
    }
});
exports.default = router;
//# sourceMappingURL=ai.js.map