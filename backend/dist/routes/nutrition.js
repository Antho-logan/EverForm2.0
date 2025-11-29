"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Nutrition routes: meals and daily summaries.
const express_1 = require("express");
const zod_1 = require("zod");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
const mealSchema = zod_1.z.object({
    mealType: zod_1.z.enum(['breakfast', 'lunch', 'dinner', 'snack']),
    title: zod_1.z.string().min(1),
    kcal: zod_1.z.number().int().nonnegative().optional(),
    proteinG: zod_1.z.number().nonnegative().optional(),
    carbsG: zod_1.z.number().nonnegative().optional(),
    fatG: zod_1.z.number().nonnegative().optional(),
    loggedAt: zod_1.z.string(),
    source: zod_1.z.string().optional()
});
router.get('/recent-meals', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await supabaseClient_1.supabase
            .from('meals')
            .select('*')
            .eq('user_id', userId)
            .order('logged_at', { ascending: false })
            .limit(3);
        if (error) {
            console.error('Failed to fetch meals', error);
            return res.status(500).json({ message: 'Could not fetch meals' });
        }
        return res.json({ meals: data ?? [] });
    }
    catch (err) {
        return next(err);
    }
});
router.get('/today', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const start = new Date();
        start.setHours(0, 0, 0, 0);
        const end = new Date();
        end.setHours(23, 59, 59, 999);
        const { data, error } = await supabaseClient_1.supabase
            .from('meals')
            .select('*')
            .eq('user_id', userId)
            .gte('logged_at', start.toISOString())
            .lte('logged_at', end.toISOString())
            .order('logged_at', { ascending: false });
        if (error) {
            console.error('Failed to fetch today\'s meals', error);
            return res.status(500).json({ message: 'Could not fetch today\'s meals' });
        }
        const meals = data ?? [];
        const totals = meals.reduce((acc, meal) => {
            acc.kcal += meal.kcal ?? 0;
            acc.protein += meal.protein_g ?? 0;
            acc.carbs += meal.carbs_g ?? 0;
            acc.fat += meal.fat_g ?? 0;
            return acc;
        }, { kcal: 0, protein: 0, carbs: 0, fat: 0 });
        const grouped = meals.reduce((acc, meal) => {
            acc[meal.meal_type] = acc[meal.meal_type] ? [...acc[meal.meal_type], meal] : [meal];
            return acc;
        }, {});
        return res.json({ totals, meals: grouped });
    }
    catch (err) {
        return next(err);
    }
});
router.post('/meal', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const parsed = mealSchema.parse(req.body);
        const payload = {
            user_id: userId,
            meal_type: parsed.mealType,
            title: parsed.title,
            kcal: parsed.kcal,
            protein_g: parsed.proteinG,
            carbs_g: parsed.carbsG,
            fat_g: parsed.fatG,
            logged_at: parsed.loggedAt,
            source: parsed.source
        };
        const { data, error } = await supabaseClient_1.supabase.from('meals').insert(payload).select().single();
        if (error) {
            console.error('Failed to create meal', error);
            return res.status(500).json({ message: 'Could not create meal' });
        }
        return res.status(201).json({ meal: data });
    }
    catch (err) {
        return next(err);
    }
});
exports.default = router;
//# sourceMappingURL=nutrition.js.map