"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Fix Pain routes: pain checks logging.
const express_1 = require("express");
const zod_1 = require("zod");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
const painCheckSchema = zod_1.z.object({
    area: zod_1.z.string().min(1),
    severity: zod_1.z.number().int().min(1).max(10),
    description: zod_1.z.string().optional()
});
router.get('/recent', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await supabaseClient_1.supabase
            .from('pain_checks')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false })
            .limit(3);
        if (error) {
            console.error('Failed to fetch pain checks', error);
            return res.status(500).json({ message: 'Could not fetch pain checks' });
        }
        return res.json({ painChecks: data ?? [] });
    }
    catch (err) {
        return next(err);
    }
});
router.post('/check', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const parsed = painCheckSchema.parse(req.body);
        const payload = {
            user_id: userId,
            area: parsed.area,
            severity: parsed.severity,
            description: parsed.description
        };
        const { data, error } = await supabaseClient_1.supabase.from('pain_checks').insert(payload).select().single();
        if (error) {
            console.error('Failed to create pain check', error);
            return res.status(500).json({ message: 'Could not create pain check' });
        }
        return res.status(201).json({ painCheck: data });
    }
    catch (err) {
        return next(err);
    }
});
exports.default = router;
//# sourceMappingURL=fixPain.js.map