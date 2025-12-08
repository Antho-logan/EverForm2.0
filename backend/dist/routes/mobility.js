"use strict";
/**
 * Mobility Routes
 * Routines and session logging.
 */
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const db_1 = require("../utils/db");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
const mobilitySessionSchema = zod_1.z.object({
    routineId: zod_1.z.string(),
    status: zod_1.z.enum(['completed', 'skipped']).default('completed'),
    performedAt: zod_1.z.string().optional()
});
/**
 * GET /api/v1/mobility/plan
 */
router.get('/plan', async (req, res) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await (0, db_1.userSelect)('mobility_plans', userId, '*')
            .order('created_at', { ascending: false })
            .limit(1)
            .maybeSingle();
        if (error) {
            console.error('[mobility] Failed to fetch plan:', error.message);
            return res.status(500).json({
                message: 'Failed to fetch mobility plan',
                error: error.message
            });
        }
        return res.json({ plan: data ?? null, status: 'ok' });
    }
    catch (err) {
        console.error('[mobility] Unexpected error in plan:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
/**
 * GET /api/v1/mobility/sessions
 */
router.get('/sessions', async (req, res) => {
    try {
        const userId = req.user?.id;
        // Need join, so use raw supabase with explicit user_id filter
        const { data, error } = await supabaseClient_1.supabase
            .from('mobility_sessions')
            .select('*, mobility_routines(name, duration_minutes)')
            .eq('user_id', userId)
            .order('performed_at', { ascending: false })
            .limit(3);
        if (error) {
            console.error('[mobility] Failed to fetch sessions:', error.message);
            return res.status(500).json({
                message: 'Failed to fetch mobility sessions',
                error: error.message
            });
        }
        return res.json({ mobilitySessions: data ?? [], status: 'ok' });
    }
    catch (err) {
        console.error('[mobility] Unexpected error in sessions:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
/**
 * POST /api/v1/mobility/sessions
 */
router.post('/sessions', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = mobilitySessionSchema.parse(req.body);
        const { data, error } = await (0, db_1.userInsert)('mobility_sessions', userId, {
            routine_id: parsed.routineId,
            status: parsed.status,
            performed_at: parsed.performedAt
        }).select().single();
        if (error) {
            console.error('[mobility] Failed to create session:', error.message);
            return res.status(500).json({
                message: 'Failed to create mobility session',
                error: error.message
            });
        }
        return res.status(201).json({ mobilitySession: data, status: 'ok' });
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[mobility] Unexpected error on create:', err);
        return res.status(500).json({ message: 'Could not create mobility session' });
    }
});
exports.default = router;
//# sourceMappingURL=mobility.js.map