"use strict";
/**
 * Recovery Routes
 * Manages recovery profiles, logs, and AI insights/plans.
 */
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const coachAgent_1 = require("../services/coachAgent");
const db_1 = require("../utils/db");
const recoveryProfileService_1 = require("../services/recoveryProfileService");
const recoverySummaryService_1 = require("../services/recoverySummaryService");
const recoveryAiService_1 = require("../services/recoveryAiService");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
// ─────────────────────────────────────────────────────────────────────────────
// Schemas
// ─────────────────────────────────────────────────────────────────────────────
const recoveryLogSchema = zod_1.z.object({
    date: zod_1.z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
    activities: zod_1.z.array(zod_1.z.string()).default([]),
    notes: zod_1.z.string().optional()
});
// Legacy schema for backward compatibility
const legacyRecoverySchema = zod_1.z.object({
    sleepHours: zod_1.z.number().nonnegative().optional(),
    sleepScore: zod_1.z.number().int().min(0).max(100).optional(),
    stressLevel: zod_1.z.number().int().min(1).max(10).optional(),
    notes: zod_1.z.string().optional(),
    loggedAt: zod_1.z.string()
});
const recoveryProfileUpdateSchema = zod_1.z.object({
    goal: zod_1.z.enum(['optimal', 'fix_insomnia', 'post_cut', 'stress_control']).optional(),
    targetSleepMinutes: zod_1.z.number().int().min(240).max(600).optional(),
    preferredBedtime: zod_1.z.string().nullable().optional(),
    preferredWakeTime: zod_1.z.string().nullable().optional(),
    caffeineCutoffHour: zod_1.z.number().int().min(0).max(23).nullable().optional(),
    timezone: zod_1.z.string().optional(),
});
const planRequestSchema = zod_1.z.object({
    date: zod_1.z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
});
// ─────────────────────────────────────────────────────────────────────────────
// Recovery Profile
// ─────────────────────────────────────────────────────────────────────────────
router.get('/profile', async (req, res) => {
    try {
        const userId = req.user?.id;
        const profile = await (0, recoveryProfileService_1.getOrCreateRecoveryProfile)(userId);
        return res.json(profile);
    }
    catch (err) {
        console.error('[recovery] GET /profile failed', err);
        return res.status(500).json({ message: 'Failed to fetch recovery profile' });
    }
});
router.put('/profile', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = recoveryProfileUpdateSchema.parse(req.body ?? {});
        const profile = await (0, recoveryProfileService_1.updateRecoveryProfile)(userId, parsed);
        return res.json(profile);
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[recovery] Failed to update recovery profile', err);
        return res.status(500).json({ message: 'Could not update recovery profile' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Recovery Logs
// ─────────────────────────────────────────────────────────────────────────────
router.post('/log', async (req, res) => {
    try {
        const userId = req.user?.id;
        // Try new schema first, fall back to legacy
        const newSchemaResult = recoveryLogSchema.safeParse(req.body);
        if (newSchemaResult.success) {
            const parsed = newSchemaResult.data;
            const { data, error } = await (0, db_1.userInsert)('recovery_logs', userId, {
                date: parsed.date,
                activities: parsed.activities,
                notes: parsed.notes
            }).select().single();
            if (error) {
                console.error('[recovery] Failed to create log:', error.message);
                return res.status(201).json({
                    log: { id: 'temp-' + Date.now(), ...parsed },
                    status: 'fallback'
                });
            }
            (0, coachAgent_1.runDailySummary)(userId, parsed.date).catch(err => {
                console.error('[recovery] Coach agent error:', err);
            });
            return res.status(201).json({ log: data, status: 'ok' });
        }
        const legacyResult = legacyRecoverySchema.safeParse(req.body);
        if (legacyResult.success) {
            const parsed = legacyResult.data;
            const logDate = parsed.loggedAt.slice(0, 10);
            const { data, error } = await (0, db_1.userInsert)('recovery_logs', userId, {
                sleep_hours: parsed.sleepHours,
                sleep_score: parsed.sleepScore,
                stress_level: parsed.stressLevel,
                notes: parsed.notes,
                logged_at: parsed.loggedAt
            }).select().single();
            if (error) {
                console.error('[recovery] Failed to create legacy log:', error.message);
                return res.status(201).json({
                    recoveryLog: { id: 'temp-' + Date.now(), ...parsed },
                    status: 'fallback'
                });
            }
            (0, coachAgent_1.runDailySummary)(userId, logDate).catch(err => {
                console.error('[recovery] Coach agent error:', err);
            });
            return res.status(201).json({ recoveryLog: data, status: 'ok' });
        }
        return res.status(400).json({ message: 'Validation failed', issues: newSchemaResult.error.issues });
    }
    catch (err) {
        console.error('[recovery] Unexpected error:', err);
        return res.status(500).json({ message: 'Could not create recovery log' });
    }
});
router.get('/logs', async (req, res) => {
    try {
        const userId = req.user?.id;
        const date = req.query.date;
        const from = req.query.from;
        const to = req.query.to;
        const limit = parseInt(req.query.limit) || 7;
        let query = (0, db_1.userSelect)('recovery_logs', userId, '*')
            .order('date', { ascending: false })
            .limit(limit);
        if (date) {
            query = query.eq('date', date);
        }
        else if (from && to) {
            query = query.gte('date', from).lte('date', to);
        }
        const { data, error } = await query;
        if (error) {
            console.error('[recovery] Failed to fetch logs:', error.message);
            return res.json({ logs: [], status: 'fallback' });
        }
        return res.json({ logs: data ?? [], status: 'ok' });
    }
    catch (err) {
        console.error('[recovery] Unexpected error:', err);
        return res.json({ logs: [], status: 'fallback' });
    }
});
router.get('/recent', async (req, res) => {
    try {
        const userId = req.user?.id;
        const [recoveryResult, painResult] = await Promise.all([
            supabaseClient_1.supabase.from('recovery_logs').select('*').eq('user_id', userId).order('created_at', { ascending: false }).limit(1),
            supabaseClient_1.supabase.from('pain_checks').select('*').eq('user_id', userId).order('created_at', { ascending: false }).limit(1),
        ]);
        const recoveryLog = recoveryResult.data?.[0] ?? null;
        const recentPainCheck = painResult.data?.[0] ?? null;
        return res.json({
            recoveryLog,
            recentPainCheck,
            status: recoveryLog || recentPainCheck ? 'ok' : 'fallback'
        });
    }
    catch (err) {
        console.error('[recovery] Unexpected error:', err);
        return res.json({
            recoveryLog: null,
            recentPainCheck: null,
            status: 'fallback'
        });
    }
});
router.get('/feedback', async (req, res) => {
    try {
        const userId = req.user?.id;
        const date = req.query.date || new Date().toISOString().slice(0, 10);
        const feedback = await (0, coachAgent_1.generateRecoveryFeedback)(userId, date);
        return res.json({ feedback, date, status: 'ok' });
    }
    catch (err) {
        console.error('[recovery] Error generating feedback:', err);
        return res.json({
            feedback: 'Log your recovery activities to get personalized feedback.',
            date: new Date().toISOString().slice(0, 10),
            status: 'fallback'
        });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// AI Insights & Plans
// ─────────────────────────────────────────────────────────────────────────────
router.get('/insights/today', async (req, res) => {
    try {
        const userId = req.user?.id;
        const context = await (0, recoverySummaryService_1.buildRecoveryAiContext)(userId);
        const insights = await (0, recoveryAiService_1.getTodayRecoveryInsights)(context);
        return res.json(insights);
    }
    catch (err) {
        console.error('[recovery/insights] Failed to generate insights', err);
        return res.status(500).json({ message: 'Failed to generate recovery insights' });
    }
});
router.post('/plan/day', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = planRequestSchema.parse(req.body ?? {});
        const date = parsed.date ?? new Date().toISOString().slice(0, 10);
        const context = await (0, recoverySummaryService_1.buildRecoveryAiContext)(userId);
        const plan = await (0, recoveryAiService_1.getSmartRecoveryPlanForDay)({ ...context, targetDate: date });
        return res.json(plan);
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[recovery/plan] Failed to generate recovery plan', err);
        return res.status(500).json({ message: 'Failed to generate recovery plan' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Curl Examples (dev)
// ─────────────────────────────────────────────────────────────────────────────
// curl -X GET http://localhost:4000/api/v1/recovery/profile
// curl -X PUT http://localhost:4000/api/v1/recovery/profile \\
//   -H \"Content-Type: application/json\" \\
//   -d '{\"goal\":\"optimal\",\"targetSleepMinutes\":480,\"caffeineCutoffHour\":16}'
// curl -X GET http://localhost:4000/api/v1/recovery/insights/today
// curl -X POST http://localhost:4000/api/v1/recovery/plan/day \\
//   -H \"Content-Type: application/json\" \\
//   -d '{\"date\":\"2025-12-10\"}'
exports.default = router;
//# sourceMappingURL=recovery.js.map