"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Training routes: workout sessions and plans.
const express_1 = require("express");
const zod_1 = require("zod");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
const sessionSchema = zod_1.z.object({
    title: zod_1.z.string().min(1),
    status: zod_1.z.enum(['completed', 'skipped', 'planned']).default('planned'),
    durationMinutes: zod_1.z.number().int().positive().optional(),
    performedAt: zod_1.z.string().optional(),
    planId: zod_1.z.string().optional(),
    notes: zod_1.z.string().optional()
});
router.get('/recent', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await supabaseClient_1.supabase
            .from('workout_sessions')
            .select('*')
            .eq('user_id', userId)
            .order('performed_at', { ascending: false })
            .limit(3);
        if (error) {
            console.error('Failed to fetch recent sessions', error);
            return res.status(500).json({ message: 'Could not fetch sessions' });
        }
        return res.json({ sessions: data ?? [] });
    }
    catch (err) {
        return next(err);
    }
});
router.post('/session', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const parsed = sessionSchema.parse(req.body);
        const payload = {
            user_id: userId,
            plan_id: parsed.planId,
            title: parsed.title,
            status: parsed.status,
            duration_minutes: parsed.durationMinutes,
            performed_at: parsed.performedAt,
            notes: parsed.notes
        };
        const { data, error } = await supabaseClient_1.supabase.from('workout_sessions').insert(payload).select().single();
        if (error) {
            console.error('Failed to create workout session', error);
            return res.status(500).json({ message: 'Could not create session' });
        }
        return res.status(201).json({ session: data });
    }
    catch (err) {
        return next(err);
    }
});
router.get('/plan', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await supabaseClient_1.supabase
            .from('workout_plans')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false })
            .limit(1)
            .maybeSingle();
        if (error) {
            console.error('Failed to fetch workout plan', error);
            return res.status(500).json({ message: 'Could not fetch workout plan' });
        }
        return res.json({ plan: data ?? null });
    }
    catch (err) {
        return next(err);
    }
});
exports.default = router;
//# sourceMappingURL=training.js.map