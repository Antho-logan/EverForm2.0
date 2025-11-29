"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Look Max routes: track aesthetic improvement sessions.
const express_1 = require("express");
const zod_1 = require("zod");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
const lookmaxRoutineSchema = zod_1.z.object({
    category: zod_1.z.enum(['hair', 'jawline', 'skin', 'posture', 'style']),
    planJson: zod_1.z.record(zod_1.z.any()).optional(),
    notes: zod_1.z.string().optional()
});
const lookmaxActionSchema = zod_1.z.object({
    routineId: zod_1.z.string(),
    action: zod_1.z.string(),
    notes: zod_1.z.string().optional()
});
router.get('/routines', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await supabaseClient_1.supabase
            .from('lookmax_sessions')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false })
            .limit(3);
        if (error) {
            console.error('Failed to fetch lookmax sessions', error);
            return res.status(500).json({ message: 'Could not fetch lookmax sessions' });
        }
        return res.json({ lookmaxSessions: data ?? [] });
    }
    catch (err) {
        return next(err);
    }
});
router.post('/routines', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const parsed = lookmaxRoutineSchema.parse(req.body);
        const payload = {
            user_id: userId,
            category: parsed.category,
            plan_json: parsed.planJson,
            notes: parsed.notes
        };
        const { data, error } = await supabaseClient_1.supabase.from('lookmax_sessions').insert(payload).select().single();
        if (error) {
            console.error('Failed to create lookmax session', error);
            return res.status(500).json({ message: 'Could not create lookmax session' });
        }
        return res.status(201).json({ lookmaxSession: data });
    }
    catch (err) {
        return next(err);
    }
});
router.post('/actions', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const parsed = lookmaxActionSchema.parse(req.body);
        const payload = {
            user_id: userId,
            session_id: parsed.routineId,
            action: parsed.action,
            notes: parsed.notes
        };
        const { data, error } = await supabaseClient_1.supabase.from('lookmax_actions').insert(payload).select().single();
        if (error) {
            console.error('Failed to create lookmax action', error);
            return res.status(500).json({ message: 'Could not create lookmax action' });
        }
        return res.status(201).json({ action: data });
    }
    catch (err) {
        return next(err);
    }
});
exports.default = router;
//# sourceMappingURL=lookMax.js.map