"use strict";
/**
 * Recovery Routes
 * Manages recovery activity logging and feedback.
 */
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const coachAgent_1 = require("../services/coachAgent");
const db_1 = require("../utils/db");
const router = (0, express_1.Router)();
// ─────────────────────────────────────────────────────────────────────────────
// Schemas
// ─────────────────────────────────────────────────────────────────────────────
const recoveryLogSchema = zod_1.z.object({
    date: zod_1.z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
    activities: zod_1.z.array(zod_1.z.string()).default([]),
    notes: zod_1.z.string().optional()
});
const legacyRecoverySchema = zod_1.z.object({
    sleepHours: zod_1.z.number().nonnegative().optional(),
    sleepScore: zod_1.z.number().int().min(0).max(100).optional(),
    stressLevel: zod_1.z.number().int().min(1).max(10).optional(),
    notes: zod_1.z.string().optional(),
    loggedAt: zod_1.z.string()
});
// ─────────────────────────────────────────────────────────────────────────────
// Recovery Logs
// ─────────────────────────────────────────────────────────────────────────────
/**
 * POST /api/v1/recovery/log
 * Triggers daily summary recalculation
 */
router.post('/log', async (req, res) => {
    try {
        const userId = req.user?.id;
        // Try new schema first
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
                return res.status(500).json({ message: 'Failed to create recovery log', error: error.message });
            }
            (0, coachAgent_1.runDailySummary)(userId, parsed.date).catch(err => {
                console.error('[recovery] Coach agent error:', err);
            });
            return res.status(201).json({ log: data, status: 'ok' });
        }
        // Legacy format
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
                return res.status(500).json({ message: 'Failed to create recovery log', error: error.message });
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
/**
 * GET /api/v1/recovery/logs
 */
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
            return res.status(500).json({ message: 'Failed to fetch logs', error: error.message });
        }
        return res.json({ logs: data ?? [], status: 'ok' });
    }
    catch (err) {
        console.error('[recovery] Unexpected error:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
/**
 * GET /api/v1/recovery/recent
 */
router.get('/recent', async (req, res) => {
    try {
        const userId = req.user?.id;
        const [recoveryResult, painResult] = await Promise.all([
            (0, db_1.userSelect)('recovery_logs', userId, '*').order('created_at', { ascending: false }).limit(1),
            (0, db_1.userSelect)('pain_checks', userId, '*').order('created_at', { ascending: false }).limit(1)
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
        return res.json({ recoveryLog: null, recentPainCheck: null, status: 'fallback' });
    }
});
/**
 * GET /api/v1/recovery/feedback
 */
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
exports.default = router;
//# sourceMappingURL=recovery.js.map