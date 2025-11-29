"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Mobility routes: routines and session logging.
const express_1 = require("express");
const zod_1 = require("zod");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
const mobilitySessionSchema = zod_1.z.object({
    routineId: zod_1.z.string(),
    status: zod_1.z.enum(['completed', 'skipped']).default('completed'),
    performedAt: zod_1.z.string().optional()
});
router.get('/plan', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await supabaseClient_1.supabase
            .from('mobility_plans')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false })
            .limit(1)
            .maybeSingle();
        if (error) {
            console.error('Failed to fetch mobility plan', error);
            return res.status(500).json({ message: 'Could not fetch mobility plan' });
        }
        return res.json({ plan: data ?? null });
    }
    catch (err) {
        return next(err);
    }
});
router.get('/sessions', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await supabaseClient_1.supabase
            .from('mobility_sessions')
            .select('*, mobility_routines(name, duration_minutes)')
            .eq('user_id', userId)
            .order('performed_at', { ascending: false })
            .limit(3);
        if (error) {
            console.error('Failed to fetch mobility sessions', error);
            return res.status(500).json({ message: 'Could not fetch mobility sessions' });
        }
        return res.json({ mobilitySessions: data ?? [] });
    }
    catch (err) {
        return next(err);
    }
});
router.post('/sessions', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const parsed = mobilitySessionSchema.parse(req.body);
        const payload = {
            user_id: userId,
            routine_id: parsed.routineId,
            status: parsed.status,
            performed_at: parsed.performedAt
        };
        const { data, error } = await supabaseClient_1.supabase.from('mobility_sessions').insert(payload).select().single();
        if (error) {
            console.error('Failed to create mobility session', error);
            return res.status(500).json({ message: 'Could not create mobility session' });
        }
        return res.status(201).json({ mobilitySession: data });
    }
    catch (err) {
        return next(err);
    }
});
exports.default = router;
//# sourceMappingURL=mobility.js.map