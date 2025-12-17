"use strict";
/**
 * Training Routes
 * Manages workout sessions, exercises, and training logs.
 */
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const coachAgent_1 = require("../services/coachAgent");
const db_1 = require("../utils/db");
const supabaseClient_1 = require("../config/supabaseClient");
const trainingProfileService_1 = require("../services/trainingProfileService");
const router = (0, express_1.Router)();
// ─────────────────────────────────────────────────────────────────────────────
// Schemas
// ─────────────────────────────────────────────────────────────────────────────
const completedSetSchema = zod_1.z.object({
    exerciseName: zod_1.z.string(),
    setNumber: zod_1.z.number().int(),
    reps: zod_1.z.number().int().nonnegative(),
    weight: zod_1.z.number().nonnegative().optional(),
    rpe: zod_1.z.number().min(1).max(10).optional(),
    notes: zod_1.z.string().optional()
});
const trainingLogSchema = zod_1.z.object({
    sessionId: zod_1.z.string().uuid().optional(),
    datePerformed: zod_1.z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
    completedSets: zod_1.z.array(completedSetSchema).default([]),
    perceivedEffort: zod_1.z.number().int().min(1).max(10),
    notes: zod_1.z.string().optional()
});
const sessionSchema = zod_1.z.object({
    templateId: zod_1.z.string().uuid().optional(),
    datePlanned: zod_1.z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
    sessionLabel: zod_1.z.string().optional()
});
const exerciseSchema = zod_1.z.object({
    sessionId: zod_1.z.string().uuid(),
    exerciseName: zod_1.z.string(),
    sets: zod_1.z.number().int().default(3),
    reps: zod_1.z.number().int().default(10),
    restSeconds: zod_1.z.number().int().default(90),
    intensityTarget: zod_1.z.string().optional(),
    orderIndex: zod_1.z.number().int().default(0)
});
const trainingProfileUpdateSchema = zod_1.z.object({
    goal: zod_1.z.enum(['muscle_gain', 'fat_loss', 'performance', 'health', 'general_fitness']).optional(),
    daysPerWeek: zod_1.z.number().int().min(0).max(14).optional(),
    experienceLevel: zod_1.z.enum(['beginner', 'intermediate', 'advanced']).optional(),
    equipmentAccess: zod_1.z.enum(['full_gym', 'limited_home', 'bodyweight_only']).optional()
});
// ─────────────────────────────────────────────────────────────────────────────
// Training Profile
// ─────────────────────────────────────────────────────────────────────────────
/**
 * GET /api/v1/training/profile
 */
router.get('/profile', async (req, res) => {
    try {
        const userId = req.user?.id;
        const profile = await (0, trainingProfileService_1.getOrCreateDefaultTrainingProfile)(userId);
        return res.json((0, trainingProfileService_1.mapTrainingProfileToResponse)(profile));
    }
    catch (err) {
        const errorMessage = err instanceof Error ? err.message : String(err);
        console.error('[training] GET /profile failed', { userId: req.user?.id, error: err });
        return res.status(500).json({ message: 'Failed to fetch training profile', error: errorMessage });
    }
});
/**
 * PUT /api/v1/training/profile
 */
router.put('/profile', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = trainingProfileUpdateSchema.parse(req.body);
        const updates = {
            ...(parsed.goal !== undefined ? { goal: parsed.goal } : {}),
            ...(parsed.daysPerWeek !== undefined ? { days_per_week: parsed.daysPerWeek } : {}),
            ...(parsed.experienceLevel !== undefined ? { experience_level: parsed.experienceLevel } : {}),
            ...(parsed.equipmentAccess !== undefined ? { equipment_access: parsed.equipmentAccess } : {})
        };
        const profile = await (0, trainingProfileService_1.updateTrainingProfile)(userId, updates);
        return res.json((0, trainingProfileService_1.mapTrainingProfileToResponse)(profile));
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[training] Failed to update training profile:', err);
        return res.status(500).json({ message: 'Could not update training profile' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Sessions (Planned Workouts)
// ─────────────────────────────────────────────────────────────────────────────
/**
 * GET /api/v1/training/sessions
 */
router.get('/sessions', async (req, res) => {
    try {
        const userId = req.user?.id;
        const { from, to } = req.query;
        // Need join, so use supabase directly with explicit user_id filter
        let query = supabaseClient_1.supabase
            .from('training_sessions')
            .select('*, training_exercises(*)')
            .eq('user_id', userId)
            .order('date_planned', { ascending: true });
        if (from && typeof from === 'string') {
            query = query.gte('date_planned', from);
        }
        if (to && typeof to === 'string') {
            query = query.lte('date_planned', to);
        }
        const { data, error } = await query;
        if (error) {
            console.error('[training] Failed to fetch sessions:', error.message);
            return res.status(500).json({ message: 'Failed to fetch sessions', error: error.message });
        }
        return res.json({ sessions: data ?? [], status: 'ok' });
    }
    catch (err) {
        console.error('[training] Unexpected error:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
/**
 * POST /api/v1/training/sessions
 */
router.post('/sessions', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = sessionSchema.parse(req.body);
        const { data, error } = await (0, db_1.userInsert)('training_sessions', userId, {
            template_id: parsed.templateId,
            date_planned: parsed.datePlanned,
            session_label: parsed.sessionLabel
        }).select().single();
        if (error) {
            console.error('[training] Failed to create session:', error.message);
            return res.status(500).json({ message: 'Failed to create session', error: error.message });
        }
        return res.status(201).json({ session: data, status: 'ok' });
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[training] Unexpected error:', err);
        return res.status(500).json({ message: 'Could not create session' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Exercises (within sessions)
// ─────────────────────────────────────────────────────────────────────────────
/**
 * POST /api/v1/training/exercises
 */
router.post('/exercises', async (req, res) => {
    try {
        const parsed = exerciseSchema.parse(req.body);
        // Note: exercises don't have user_id directly, they're linked through session
        const { data, error } = await supabaseClient_1.supabase
            .from('training_exercises')
            .insert({
            session_id: parsed.sessionId,
            exercise_name: parsed.exerciseName,
            sets: parsed.sets,
            reps: parsed.reps,
            rest_seconds: parsed.restSeconds,
            intensity_target: parsed.intensityTarget,
            order_index: parsed.orderIndex
        })
            .select()
            .single();
        if (error) {
            console.error('[training] Failed to create exercise:', error.message);
            return res.status(500).json({ message: 'Failed to create exercise', error: error.message });
        }
        return res.status(201).json({ exercise: data, status: 'ok' });
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[training] Unexpected error:', err);
        return res.status(500).json({ message: 'Could not create exercise' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Training Logs (Completed Workouts)
// ─────────────────────────────────────────────────────────────────────────────
/**
 * GET /api/v1/training/logs
 */
router.get('/logs', async (req, res) => {
    try {
        const userId = req.user?.id;
        const { from, to, limit } = req.query;
        let query = (0, db_1.userSelect)('training_logs', userId, '*')
            .order('date_performed', { ascending: false });
        if (from && typeof from === 'string') {
            query = query.gte('date_performed', from);
        }
        if (to && typeof to === 'string') {
            query = query.lte('date_performed', to);
        }
        if (limit) {
            query = query.limit(parseInt(limit));
        }
        const { data, error } = await query;
        if (error) {
            console.error('[training] Failed to fetch logs:', error.message);
            return res.status(500).json({ message: 'Failed to fetch logs', error: error.message });
        }
        return res.json({ logs: data ?? [], status: 'ok' });
    }
    catch (err) {
        console.error('[training] Unexpected error:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
/**
 * POST /api/v1/training/log
 * Triggers daily summary recalculation
 */
router.post('/log', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = trainingLogSchema.parse(req.body);
        const { data, error } = await (0, db_1.userInsert)('training_logs', userId, {
            session_id: parsed.sessionId,
            date_performed: parsed.datePerformed,
            completed_sets: parsed.completedSets,
            perceived_effort: parsed.perceivedEffort,
            notes: parsed.notes
        }).select().single();
        if (error) {
            console.error('[training] Failed to create log:', error.message);
            return res.status(500).json({ message: 'Failed to create training log', error: error.message });
        }
        // Trigger coach agent to update daily summary (fire and forget)
        (0, coachAgent_1.runDailySummary)(userId, parsed.datePerformed).catch(err => {
            console.error('[training] Coach agent error:', err);
        });
        return res.status(201).json({ log: data, status: 'ok' });
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[training] Unexpected error:', err);
        return res.status(500).json({ message: 'Could not create training log' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Templates
// ─────────────────────────────────────────────────────────────────────────────
/**
 * GET /api/v1/training/templates
 */
router.get('/templates', async (req, res) => {
    try {
        const { data, error } = await supabaseClient_1.supabase
            .from('training_templates')
            .select('*')
            .order('name', { ascending: true });
        if (error) {
            console.error('[training] Failed to fetch templates:', error.message);
            return res.status(500).json({ message: 'Failed to fetch templates', error: error.message });
        }
        return res.json({ templates: data ?? [], status: 'ok' });
    }
    catch (err) {
        console.error('[training] Unexpected error:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
/**
 * GET /api/v1/training/plan
 * Legacy compatibility endpoint
 */
router.get('/plan', async (req, res) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await (0, db_1.userSelect)('ai_plans', userId, '*')
            .eq('type', 'training')
            .order('created_at', { ascending: false })
            .limit(1)
            .maybeSingle();
        if (error) {
            console.error('[training] Failed to fetch plan:', error.message);
            return res.status(500).json({ message: 'Failed to fetch plan', error: error.message });
        }
        return res.json({ plan: data ?? null, status: 'ok' });
    }
    catch (err) {
        console.error('[training] Unexpected error:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
exports.default = router;
//# sourceMappingURL=training.js.map