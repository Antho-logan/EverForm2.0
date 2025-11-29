"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Training routes: workout sessions and plans.
const express_1 = require("express");
const zod_1 = require("zod");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
const setSchema = zod_1.z.object({
    exercise: zod_1.z.string(),
    reps: zod_1.z.number().int().nonnegative(),
    weight: zod_1.z.number().nonnegative().optional(),
    rpe: zod_1.z.number().nonnegative().optional(),
    notes: zod_1.z.string().optional()
});
const sessionSchema = zod_1.z.object({
    title: zod_1.z.string().min(1),
    status: zod_1.z.enum(['completed', 'skipped', 'planned']).default('completed'),
    durationMinutes: zod_1.z.number().int().positive().optional(),
    performedAt: zod_1.z.string().optional(),
    planId: zod_1.z.string().optional(),
    notes: zod_1.z.string().optional(),
    sets: zod_1.z.array(setSchema).optional()
});
router.get('/sessions', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const { from, to } = req.query;
        const query = supabaseClient_1.supabase
            .from('training_sessions')
            .select('*, training_sets(*)')
            .eq('user_id', userId)
            .order('performed_at', { ascending: false });
        if (from && typeof from === 'string') {
            query.gte('performed_at', from);
        }
        if (to && typeof to === 'string') {
            query.lte('performed_at', to);
        }
        const { data, error } = await query;
        if (error) {
            console.error('Failed to fetch training sessions', error);
            return res.status(500).json({ message: 'Could not fetch training sessions' });
        }
        return res.json({ sessions: data ?? [] });
    }
    catch (err) {
        return next(err);
    }
});
router.post('/sessions', async (req, res, next) => {
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
        const { data: session, error } = await supabaseClient_1.supabase.from('training_sessions').insert(payload).select().single();
        if (error) {
            console.error('Failed to create training session', error);
            return res.status(500).json({ message: 'Could not create training session' });
        }
        // Insert nested sets if provided
        if (parsed.sets && parsed.sets.length > 0 && session?.id) {
            const setsPayload = parsed.sets.map((set) => ({
                user_id: userId,
                session_id: session.id,
                exercise: set.exercise,
                reps: set.reps,
                weight: set.weight,
                rpe: set.rpe,
                notes: set.notes
            }));
            const { error: setError } = await supabaseClient_1.supabase.from('training_sets').insert(setsPayload);
            if (setError) {
                console.error('Failed to insert training sets', setError);
            }
        }
        return res.status(201).json({ session });
    }
    catch (err) {
        return next(err);
    }
});
router.get('/plan', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await supabaseClient_1.supabase
            .from('ai_plans')
            .select('*')
            .eq('user_id', userId)
            .eq('type', 'training')
            .order('created_at', { ascending: false })
            .limit(1)
            .maybeSingle();
        if (error) {
            console.error('Failed to fetch training plan', error);
            return res.status(500).json({ message: 'Could not fetch training plan' });
        }
        return res.json({ plan: data ?? null });
    }
    catch (err) {
        return next(err);
    }
});
exports.default = router;
//# sourceMappingURL=training.js.map