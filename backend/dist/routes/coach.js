"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const aiService_1 = require("../services/aiService");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
const messageSchema = zod_1.z.object({
    message: zod_1.z.string().min(1),
    context: zod_1.z.record(zod_1.z.any()).optional()
});
router.post('/message', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const parseResult = messageSchema.safeParse(req.body);
        if (!parseResult.success) {
            return res.status(400).json({ error: 'Invalid payload' });
        }
        const { message, context: clientContext } = parseResult.data;
        // Gather rich context from DB
        const { data: profile } = await supabaseClient_1.supabase.from('profiles').select('*').eq('user_id', userId).maybeSingle();
        const { data: recentMeals } = await supabaseClient_1.supabase
            .from('nutrition_meals')
            .select('*')
            .eq('user_id', userId)
            .order('logged_at', { ascending: false })
            .limit(3);
        const fullContext = {
            ...clientContext,
            profile,
            recentMeals: recentMeals ?? undefined
        };
        const reply = await (0, aiService_1.generateCoachReply)(message, fullContext);
        return res.json({ reply });
    }
    catch (err) {
        return next(err);
    }
});
exports.default = router;
//# sourceMappingURL=coach.js.map