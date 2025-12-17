"use strict";
/**
 * Breathwork Routes
 * Patterns, session logging, and recent sessions.
 */
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const db_1 = require("../utils/db");
const breathworkAiService_1 = require("../services/breathworkAiService");
const router = (0, express_1.Router)();
const BREATHWORK_PATTERNS = [
    {
        id: 'wim-hof',
        type: 'wimHof',
        displayName: 'Wim Hof Method',
        description: 'Deep breathing rounds followed by breath retention. Boosts energy and immune system.',
        targetEffect: 'Energy & Immunity',
        defaultRounds: 3,
        phases: [
            { type: 'Inhale', durationSeconds: 2.0, instruction: 'Fully in' },
            { type: 'Exhale', durationSeconds: 1.5, instruction: 'Let go' }
        ]
    },
    {
        id: 'box-breathing',
        type: 'box',
        displayName: 'Box Breathing',
        description: 'Equal duration for inhale, hold, exhale, and hold. Great for focus and stress relief.',
        targetEffect: 'Focus & Calm',
        defaultRounds: 4,
        phases: [
            { type: 'Inhale', durationSeconds: 4, instruction: 'Inhale through nose' },
            { type: 'Hold', durationSeconds: 4, instruction: 'Hold breath' },
            { type: 'Exhale', durationSeconds: 4, instruction: 'Exhale through mouth' },
            { type: 'Hold', durationSeconds: 4, instruction: 'Hold empty' }
        ]
    },
    {
        id: '4-7-8-sleep',
        type: 'fourSevenEight',
        displayName: '4-7-8 Sleep',
        description: 'Natural tranquilizer for the nervous system.',
        targetEffect: 'Sleep',
        defaultRounds: 4,
        phases: [
            { type: 'Inhale', durationSeconds: 4, instruction: 'Quiet inhale through nose' },
            { type: 'Hold', durationSeconds: 7, instruction: 'Hold breath' },
            { type: 'Exhale', durationSeconds: 8, instruction: 'Whoosh exhale through mouth' }
        ]
    },
    {
        id: 'coherent-breathing',
        type: 'coherent',
        displayName: 'Coherent Breathing',
        description: '5.5-second inhale, 5.5-second exhale. Balances the nervous system.',
        targetEffect: 'Balance',
        defaultRounds: 5,
        phases: [
            { type: 'Inhale', durationSeconds: 5.5, instruction: 'Inhale 5.5s' },
            { type: 'Exhale', durationSeconds: 5.5, instruction: 'Exhale 5.5s' }
        ]
    }
];
// ─────────────────────────────────────────────────────────────────────────────
// VALIDATION SCHEMAS
// ─────────────────────────────────────────────────────────────────────────────
const createSessionSchema = zod_1.z.object({
    patternId: zod_1.z.string().min(1),
    patternName: zod_1.z.string().min(1),
    roundsCompleted: zod_1.z.number().int().nonnegative(),
    durationSeconds: zod_1.z.number().int().nonnegative(),
    longestHoldSeconds: zod_1.z.number().int().nonnegative().optional(),
    notes: zod_1.z.string().optional()
});
// ─────────────────────────────────────────────────────────────────────────────
// ROUTES
// ─────────────────────────────────────────────────────────────────────────────
/**
 * GET /api/v1/breathwork/patterns
 */
router.get('/patterns', async (_req, res) => {
    return res.json({ patterns: BREATHWORK_PATTERNS, status: 'ok' });
});
/**
 * GET /api/v1/breathwork/sessions/recent
 */
router.get('/sessions/recent', async (req, res) => {
    try {
        const userId = req.user?.id;
        const limit = Math.min(parseInt(req.query.limit) || 10, 50);
        const { data, error } = await (0, db_1.userSelect)('breathwork_sessions', userId, '*')
            .order('completed_at', { ascending: false })
            .limit(limit);
        if (error) {
            console.error('[breathwork] Failed to fetch recent sessions:', error.message);
            return res.status(500).json({ message: 'Failed to fetch sessions', error: error.message });
        }
        const sessions = (data ?? []).map((row) => ({
            id: row.id,
            patternId: row.pattern_id ?? row.technique,
            patternName: row.pattern_name ?? row.technique,
            durationSeconds: (row.duration_minutes ?? 0) * 60,
            roundsCompleted: row.rounds_completed ?? 0,
            longestHoldSeconds: row.longest_hold_seconds ?? 0,
            notes: row.notes ?? null,
            createdAt: row.completed_at ?? row.created_at
        }));
        return res.json({ sessions, status: 'ok' });
    }
    catch (err) {
        console.error('[breathwork] Unexpected error:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
/**
 * GET /api/v1/breathwork/sessions
 */
router.get('/sessions', async (req, res) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await (0, db_1.userSelect)('breathwork_sessions', userId, '*')
            .order('completed_at', { ascending: false })
            .limit(3);
        if (error) {
            console.error('[breathwork] Failed to fetch sessions:', error.message);
            return res.status(500).json({ message: 'Failed to fetch sessions', error: error.message });
        }
        return res.json({ breathworkSessions: data ?? [], status: 'ok' });
    }
    catch (err) {
        console.error('[breathwork] Unexpected error:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
/**
 * POST /api/v1/breathwork/sessions
 */
router.post('/sessions', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = createSessionSchema.parse(req.body);
        const { data, error } = await (0, db_1.userInsert)('breathwork_sessions', userId, {
            pattern_id: parsed.patternId,
            pattern_name: parsed.patternName,
            technique: parsed.patternName,
            duration_minutes: Math.round(parsed.durationSeconds / 60),
            rounds_completed: parsed.roundsCompleted,
            longest_hold_seconds: parsed.longestHoldSeconds ?? 0,
            notes: parsed.notes ?? null,
            completed_at: new Date().toISOString()
        }).select().single();
        if (error) {
            console.error('[breathwork] Failed to create session:', error.message);
            return res.status(500).json({ message: 'Failed to create session', error: error.message });
        }
        const session = {
            id: data.id,
            patternId: data.pattern_id,
            patternName: data.pattern_name,
            durationSeconds: (data.duration_minutes ?? 0) * 60,
            roundsCompleted: data.rounds_completed ?? 0,
            longestHoldSeconds: data.longest_hold_seconds ?? 0,
            notes: data.notes,
            createdAt: data.completed_at ?? data.created_at
        };
        return res.status(201).json({ session, status: 'ok' });
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Invalid request body', errors: err.errors });
        }
        console.error('[breathwork] Unexpected error:', err);
        return res.status(500).json({ message: 'Could not create breathwork session' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// AI Coach
// ─────────────────────────────────────────────────────────────────────────────
const isoDateString = zod_1.z.string().regex(/^\d{4}-\d{2}-\d{2}/);
router.get('/ai/today', async (req, res) => {
    try {
        const userId = req.user?.id;
        const suggestion = await (0, breathworkAiService_1.getTodaySuggestion)(userId);
        return res.json(suggestion);
    }
    catch (err) {
        console.error('[breathwork] ai/today failed', err);
        return res.status(500).json({ message: 'Failed to generate breathwork suggestion' });
    }
});
router.get('/ai/weekly-insight', async (req, res) => {
    try {
        const userId = req.user?.id;
        const from = req.query.from ? isoDateString.parse(String(req.query.from)) : undefined;
        const to = req.query.to ? isoDateString.parse(String(req.query.to)) : undefined;
        const insight = await (0, breathworkAiService_1.getWeeklyInsight)(userId, from, to);
        return res.json(insight);
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[breathwork] ai/weekly-insight failed', err);
        return res.status(500).json({ message: 'Failed to generate weekly breathwork insight' });
    }
});
exports.default = router;
//# sourceMappingURL=breathwork.js.map