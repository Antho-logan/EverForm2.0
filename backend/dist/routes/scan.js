"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const scanService_1 = require("../services/scanService");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
const analyzeSchema = zod_1.z.object({
    mode: zod_1.z.enum(['calories', 'ingredients', 'plate']),
    imageBase64: zod_1.z.string().min(1)
});
router.post('/analyze', async (req, res) => {
    try {
        const parseResult = analyzeSchema.safeParse(req.body);
        if (!parseResult.success) {
            return res.status(400).json({ error: 'Invalid payload: mode (calories|ingredients|plate) and imageBase64 required' });
        }
        const result = await (0, scanService_1.analyzeImage)(parseResult.data);
        return res.json(result);
    }
    catch (err) {
        console.error('Analyze route error:', err);
        return res.status(500).json({ error: 'Internal server error' });
    }
});
// Normalized meal creation from scan
router.post('/meal', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const parseResult = analyzeSchema.safeParse(req.body);
        if (!parseResult.success) {
            return res.status(400).json({ error: 'Invalid payload' });
        }
        const result = await (0, scanService_1.analyzeImage)(parseResult.data);
        const payload = {
            user_id: userId,
            meal_type: 'scan',
            title: result.description ?? 'Scanned meal',
            kcal: result.calories ?? result.caloriesEstimate ?? null,
            protein_g: result.protein ?? null,
            carbs_g: result.carbs ?? null,
            fat_g: result.fat ?? null,
            logged_at: new Date().toISOString(),
            source: 'scan'
        };
        const { data, error } = await supabaseClient_1.supabase.from('nutrition_meals').insert(payload).select().single();
        if (error) {
            console.error('Failed to store scanned meal', error);
            return res.status(500).json({ error: 'Failed to store scanned meal' });
        }
        return res.json({ meal: data, analysis: result });
    }
    catch (err) {
        return next(err);
    }
});
exports.default = router;
//# sourceMappingURL=scan.js.map