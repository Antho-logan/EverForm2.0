"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Look Max routes: track aesthetic improvement sessions.
const express_1 = require("express");
const zod_1 = require("zod");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
const lookmaxSchema = zod_1.z.object({
    category: zod_1.z.enum(['hair', 'jawline', 'skin', 'posture', 'style']),
    planJson: zod_1.z.record(zod_1.z.any()).optional(),
    notes: zod_1.z.string().optional()
});
router.get('/recent', async (req, res, next) => {
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
router.post('/session', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const parsed = lookmaxSchema.parse(req.body);
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
exports.default = router;
//# sourceMappingURL=lookMax.js.map