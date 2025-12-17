"use strict";
/**
 * Nutrition Routes
 * Manages meal logging, nutrition targets, and daily summaries.
 */
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const coachAgent_1 = require("../services/coachAgent");
const db_1 = require("../utils/db");
const supabaseClient_1 = require("../config/supabaseClient");
const nutritionProfileService_1 = require("../services/nutritionProfileService");
const nutritionAiService_1 = require("../services/nutritionAiService");
const router = (0, express_1.Router)();
// ─────────────────────────────────────────────────────────────────────────────
// Schemas
// ─────────────────────────────────────────────────────────────────────────────
const nutritionProfileUpdateSchema = zod_1.z.object({
    goal: zod_1.z.enum(['maintenance', 'fat_loss', 'recomposition', 'muscle_gain', 'performance', 'longevity']).optional(),
    calorieTarget: zod_1.z.number().int().min(1200).max(5000).optional(),
    proteinTargetG: zod_1.z.number().int().min(40).max(350).optional(),
    carbTargetG: zod_1.z.number().int().min(40).max(600).optional(),
    fatTargetG: zod_1.z.number().int().min(20).max(200).optional(),
    dietType: zod_1.z.enum(['omnivore', 'high_protein', 'mediterranean', 'vegetarian', 'vegan', 'low_carb', 'low_fat']).optional(),
    constraints: zod_1.z
        .object({
        glutenFree: zod_1.z.boolean().optional(),
        dairyFree: zod_1.z.boolean().optional(),
        nutAllergy: zod_1.z.boolean().optional(),
        halal: zod_1.z.boolean().optional(),
        kosher: zod_1.z.boolean().optional(),
        pescatarian: zod_1.z.boolean().optional(),
    })
        .partial()
        .optional(),
    biohackerFlags: zod_1.z
        .object({
        fastingWindowStart: zod_1.z.string().regex(/^\d{2}:\d{2}$/).optional(),
        fastingWindowEnd: zod_1.z.string().regex(/^\d{2}:\d{2}$/).optional(),
        caffeineCutoffHour: zod_1.z.number().int().min(0).max(23).optional(),
        lateMealCutoffHour: zod_1.z.number().int().min(0).max(23).optional(),
    })
        .partial()
        .optional(),
});
const nutritionLogSchema = zod_1.z.object({
    date: zod_1.z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
    mealType: zod_1.z.enum(['breakfast', 'lunch', 'dinner', 'snack', 'pre_workout', 'post_workout']),
    foodName: zod_1.z.string().min(1),
    calories: zod_1.z.number().nonnegative().default(0),
    proteinG: zod_1.z.number().nonnegative().default(0),
    carbsG: zod_1.z.number().nonnegative().default(0),
    fatG: zod_1.z.number().nonnegative().default(0)
});
const nutritionTargetsSchema = zod_1.z.object({
    dailyCalories: zod_1.z.number().nonnegative().optional(),
    proteinG: zod_1.z.number().nonnegative().optional(),
    carbsG: zod_1.z.number().nonnegative().optional(),
    fatG: zod_1.z.number().nonnegative().optional()
});
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
const planRequestSchema = zod_1.z.object({
    date: zod_1.z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
});
// ─────────────────────────────────────────────────────────────────────────────
// Nutrition Profile
// ─────────────────────────────────────────────────────────────────────────────
/**
 * GET /api/v1/nutrition/profile
 */
router.get('/profile', async (req, res) => {
    try {
        const userId = req.user?.id;
        const profile = await (0, nutritionProfileService_1.getOrCreateDefaultNutritionProfile)(userId);
        return res.json(profile);
    }
    catch (err) {
        console.error('[nutrition] GET /profile failed', err);
        return res.status(500).json({ message: 'Failed to fetch nutrition profile' });
    }
});
/**
 * PUT /api/v1/nutrition/profile
 */
router.put('/profile', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = nutritionProfileUpdateSchema.parse(req.body);
        const profile = await (0, nutritionProfileService_1.updateNutritionProfile)(userId, parsed);
        return res.json(profile);
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[nutrition] Failed to update nutrition profile', err);
        return res.status(500).json({ message: 'Could not update nutrition profile' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Nutrition Logs (New API)
// ─────────────────────────────────────────────────────────────────────────────
/**
 * POST /api/v1/nutrition/log
 * Triggers daily summary recalculation
 */
router.post('/log', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = nutritionLogSchema.parse(req.body);
        const { data, error } = await (0, db_1.userInsert)('nutrition_logs', userId, {
            date: parsed.date,
            meal_type: parsed.mealType,
            food_name: parsed.foodName,
            calories: parsed.calories,
            protein_g: parsed.proteinG,
            carbs_g: parsed.carbsG,
            fat_g: parsed.fatG
        }).select().single();
        if (error) {
            console.error('[nutrition] Failed to create log:', error.message);
            return res.status(500).json({ message: 'Failed to create nutrition log', error: error.message });
        }
        // Trigger coach agent (fire and forget)
        (0, coachAgent_1.runDailySummary)(userId, parsed.date).catch(err => {
            console.error('[nutrition] Coach agent error:', err);
        });
        return res.status(201).json({ log: data, status: 'ok' });
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[nutrition] Unexpected error:', err);
        return res.status(500).json({ message: 'Could not create nutrition log' });
    }
});
/**
 * GET /api/v1/nutrition/logs
 */
router.get('/logs', async (req, res) => {
    try {
        const userId = req.user?.id;
        const date = req.query.date || new Date().toISOString().slice(0, 10);
        const from = req.query.from;
        const to = req.query.to;
        let query = (0, db_1.userSelect)('nutrition_logs', userId, '*')
            .order('created_at', { ascending: true });
        if (from && to) {
            query = query.gte('date', from).lte('date', to);
        }
        else {
            query = query.eq('date', date);
        }
        const { data, error } = await query;
        if (error) {
            console.error('[nutrition] Failed to fetch logs:', error.message);
            return res.status(500).json({ message: 'Failed to fetch logs', error: error.message });
        }
        return res.json({ logs: data ?? [], status: 'ok' });
    }
    catch (err) {
        console.error('[nutrition] Unexpected error:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Nutrition Targets
// ─────────────────────────────────────────────────────────────────────────────
/**
 * GET /api/v1/nutrition/targets
 */
router.get('/targets', async (req, res) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await (0, db_1.userSelect)('nutrition_targets', userId, '*').maybeSingle();
        if (error) {
            console.error('[nutrition] Failed to fetch targets:', error.message);
            return res.status(500).json({ message: 'Failed to fetch targets', error: error.message });
        }
        return res.json({ targets: data, status: 'ok' });
    }
    catch (err) {
        console.error('[nutrition] Unexpected error:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
/**
 * POST /api/v1/nutrition/targets
 */
router.post('/targets', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = nutritionTargetsSchema.parse(req.body);
        const { data, error } = await (0, db_1.userUpsert)('nutrition_targets', userId, {
            daily_calories: parsed.dailyCalories,
            protein_g: parsed.proteinG,
            carbs_g: parsed.carbsG,
            fat_g: parsed.fatG,
            updated_at: new Date().toISOString()
        }).select().single();
        if (error) {
            console.error('[nutrition] Failed to upsert targets:', error.message);
            return res.status(500).json({ message: 'Failed to save targets', error: error.message });
        }
        return res.status(201).json({ targets: data, status: 'ok' });
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[nutrition] Unexpected error:', err);
        return res.status(500).json({ message: 'Could not save targets' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Daily Summary (Aggregated)
// ─────────────────────────────────────────────────────────────────────────────
/**
 * GET /api/v1/nutrition/summary
 */
router.get('/summary', async (req, res) => {
    try {
        const userId = req.user?.id;
        const date = req.query.date || new Date().toISOString().slice(0, 10);
        const [logsResult, mealsResult, targetsResult] = await Promise.all([
            supabaseClient_1.supabase.from('nutrition_logs').select('*').eq('user_id', userId).eq('date', date),
            supabaseClient_1.supabase.from('nutrition_meals').select('*').eq('user_id', userId)
                .gte('logged_at', `${date}T00:00:00`).lte('logged_at', `${date}T23:59:59`),
            supabaseClient_1.supabase.from('nutrition_targets').select('*').eq('user_id', userId).maybeSingle()
        ]);
        if (logsResult.error || mealsResult.error) {
            console.error('[nutrition] Failed to fetch summary data');
            return res.status(500).json({ message: 'Failed to fetch nutrition summary' });
        }
        const logs = logsResult.data ?? [];
        const meals = mealsResult.data ?? [];
        const logsTotal = logs.reduce((acc, l) => ({
            kcal: acc.kcal + (l.calories ?? 0),
            protein: acc.protein + (l.protein_g ?? 0),
            carbs: acc.carbs + (l.carbs_g ?? 0),
            fat: acc.fat + (l.fat_g ?? 0)
        }), { kcal: 0, protein: 0, carbs: 0, fat: 0 });
        const mealsTotal = meals.reduce((acc, m) => ({
            kcal: acc.kcal + (m.kcal ?? 0),
            protein: acc.protein + (m.protein_g ?? 0),
            carbs: acc.carbs + (m.carbs_g ?? 0),
            fat: acc.fat + (m.fat_g ?? 0)
        }), { kcal: 0, protein: 0, carbs: 0, fat: 0 });
        const totals = {
            kcal: logsTotal.kcal + mealsTotal.kcal,
            protein: logsTotal.protein + mealsTotal.protein,
            carbs: logsTotal.carbs + mealsTotal.carbs,
            fat: logsTotal.fat + mealsTotal.fat
        };
        return res.json({
            date,
            totals,
            targets: targetsResult.data ?? null,
            logs,
            meals,
            mealsLoggedToday: logs.length + meals.length,
            status: 'ok'
        });
    }
    catch (err) {
        console.error('[nutrition] Unexpected error:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// AI Insights & Smart Day Plan
// ─────────────────────────────────────────────────────────────────────────────
/**
 * GET /api/v1/nutrition/insights/today
 */
router.get('/insights/today', async (req, res) => {
    try {
        const userId = req.user?.id;
        const date = new Date().toISOString().slice(0, 10);
        const result = await (0, nutritionAiService_1.generateDailyNutritionInsights)(userId, date);
        return res.json(result);
    }
    catch (err) {
        console.error('[nutrition/insights] Failed to generate insights', err);
        return res.status(500).json({ message: 'Failed to generate nutrition insights' });
    }
});
/**
 * POST /api/v1/nutrition/plan/day
 */
router.post('/plan/day', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = planRequestSchema.parse(req.body ?? {});
        const date = parsed.date ?? new Date().toISOString().slice(0, 10);
        const result = await (0, nutritionAiService_1.generateSmartDayPlan)(userId, date);
        return res.json(result);
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[nutrition/plan] Failed to generate smart day plan', err);
        return res.status(500).json({ message: 'Failed to generate smart day plan' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Legacy Meals API (Backward Compatibility)
// ─────────────────────────────────────────────────────────────────────────────
router.get('/meals', async (req, res) => {
    try {
        const userId = req.user?.id;
        const date = req.query.date || new Date().toISOString().slice(0, 10);
        const start = new Date(date);
        start.setHours(0, 0, 0, 0);
        const end = new Date(start);
        end.setHours(23, 59, 59, 999);
        const { data, error } = await supabaseClient_1.supabase
            .from('nutrition_meals')
            .select('*')
            .eq('user_id', userId)
            .gte('logged_at', start.toISOString())
            .lte('logged_at', end.toISOString())
            .order('logged_at', { ascending: false });
        if (error) {
            console.error('[nutrition] Failed to fetch meals:', error.message);
            return res.status(500).json({ message: 'Failed to fetch meals', error: error.message });
        }
        return res.json({ meals: data ?? [], status: 'ok' });
    }
    catch (err) {
        console.error('[nutrition] Unexpected error:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
router.post('/meals', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = mealSchema.parse(req.body);
        const { data, error } = await (0, db_1.userInsert)('nutrition_meals', userId, {
            meal_type: parsed.mealType,
            title: parsed.title,
            kcal: parsed.kcal,
            protein_g: parsed.proteinG,
            carbs_g: parsed.carbsG,
            fat_g: parsed.fatG,
            logged_at: parsed.loggedAt,
            source: parsed.source
        }).select().single();
        if (error) {
            console.error('[nutrition] Failed to create meal:', error.message);
            return res.status(500).json({ message: 'Failed to create meal', error: error.message });
        }
        // Trigger daily summary (fire and forget)
        const mealDate = parsed.loggedAt.slice(0, 10);
        (0, coachAgent_1.runDailySummary)(userId, mealDate).catch(err => {
            console.error('[nutrition] Coach agent error:', err);
        });
        return res.status(201).json({ meal: data, status: 'ok' });
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[nutrition] Unexpected error:', err);
        return res.status(500).json({ message: 'Could not create meal' });
    }
});
exports.default = router;
//# sourceMappingURL=nutrition.js.map