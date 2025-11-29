"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Breathwork routes: breathing session logging.
const express_1 = require("express");
const zod_1 = require("zod");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
const breathworkSchema = zod_1.z.object({
    technique: zod_1.z.string().min(1),
    durationMinutes: zod_1.z.number().int().positive().optional(),
    completedAt: zod_1.z.string().optional()
});
router.get('/sessions', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await supabaseClient_1.supabase
            .from('breathwork_sessions')
            .select('*')
            .eq('user_id', userId)
            .order('completed_at', { ascending: false })
            .limit(3);
        if (error) {
            console.error('Failed to fetch breathwork sessions', error);
            return res.status(500).json({ message: 'Could not fetch breathwork sessions' });
        }
        return res.json({ breathworkSessions: data ?? [] });
    }
    catch (err) {
        return next(err);
    }
});
router.post('/sessions', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const parsed = breathworkSchema.parse(req.body);
        const payload = {
            user_id: userId,
            technique: parsed.technique,
            duration_minutes: parsed.durationMinutes,
            completed_at: parsed.completedAt
        };
        const { data, error } = await supabaseClient_1.supabase.from('breathwork_sessions').insert(payload).select().single();
        if (error) {
            console.error('Failed to create breathwork session', error);
            return res.status(500).json({ message: 'Could not create breathwork session' });
        }
        return res.status(201).json({ breathworkSession: data });
    }
    catch (err) {
        return next(err);
    }
});
exports.default = router;
//# sourceMappingURL=breathwork.js.map