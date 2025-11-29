"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Recovery routes: sleep/stress logging.
const express_1 = require("express");
const zod_1 = require("zod");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
const recoverySchema = zod_1.z.object({
    sleepHours: zod_1.z.number().nonnegative().optional(),
    sleepScore: zod_1.z.number().int().min(0).max(100).optional(),
    stressLevel: zod_1.z.number().int().min(1).max(10).optional(),
    notes: zod_1.z.string().optional(),
    loggedAt: zod_1.z.string()
});
router.get('/recent', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const { data: recoveryLogs, error } = await supabaseClient_1.supabase
            .from('recovery_logs')
            .select('*')
            .eq('user_id', userId)
            .order('logged_at', { ascending: false })
            .limit(1);
        const { data: painChecks, error: painError } = await supabaseClient_1.supabase
            .from('pain_checks')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false })
            .limit(1);
        if (error || painError) {
            console.error('Failed to fetch recovery logs', error || painError);
            return res.status(500).json({ message: 'Could not fetch recovery data' });
        }
        return res.json({
            recoveryLog: recoveryLogs?.[0] ?? null,
            recentPainCheck: painChecks?.[0] ?? null
        });
    }
    catch (err) {
        return next(err);
    }
});
router.post('/log', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const parsed = recoverySchema.parse(req.body);
        const payload = {
            user_id: userId,
            sleep_hours: parsed.sleepHours,
            sleep_score: parsed.sleepScore,
            stress_level: parsed.stressLevel,
            notes: parsed.notes,
            logged_at: parsed.loggedAt
        };
        const { data, error } = await supabaseClient_1.supabase.from('recovery_logs').insert(payload).select().single();
        if (error) {
            console.error('Failed to create recovery log', error);
            return res.status(500).json({ message: 'Could not create recovery log' });
        }
        return res.status(201).json({ recoveryLog: data });
    }
    catch (err) {
        return next(err);
    }
});
exports.default = router;
//# sourceMappingURL=recovery.js.map