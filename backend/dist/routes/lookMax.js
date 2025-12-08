"use strict";
/**
 * Look Max Routes
 * Track aesthetic improvement sessions.
 */
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const db_1 = require("../utils/db");
const router = (0, express_1.Router)();
const lookmaxRoutineSchema = zod_1.z.object({
    category: zod_1.z.enum(['hair', 'jawline', 'skin', 'posture', 'style']),
    planJson: zod_1.z.record(zod_1.z.any()).optional(),
    notes: zod_1.z.string().optional()
});
const lookmaxActionSchema = zod_1.z.object({
    routineId: zod_1.z.string(),
    action: zod_1.z.string(),
    notes: zod_1.z.string().optional()
});
/**
 * GET /api/v1/lookmax/routines
 */
router.get('/routines', async (req, res) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await (0, db_1.userSelect)('lookmax_sessions', userId, '*')
            .order('created_at', { ascending: false })
            .limit(3);
        if (error) {
            console.error('[lookmax] Failed to fetch sessions:', error.message);
            return res.status(500).json({ message: 'Could not fetch lookmax sessions', error: error.message });
        }
        return res.json({ lookmaxSessions: data ?? [], status: 'ok' });
    }
    catch (err) {
        console.error('[lookmax] Unexpected error:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
/**
 * POST /api/v1/lookmax/routines
 */
router.post('/routines', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = lookmaxRoutineSchema.parse(req.body);
        const { data, error } = await (0, db_1.userInsert)('lookmax_sessions', userId, {
            category: parsed.category,
            plan_json: parsed.planJson,
            notes: parsed.notes
        }).select().single();
        if (error) {
            console.error('[lookmax] Failed to create session:', error.message);
            return res.status(500).json({ message: 'Could not create lookmax session', error: error.message });
        }
        return res.status(201).json({ lookmaxSession: data, status: 'ok' });
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[lookmax] Unexpected error:', err);
        return res.status(500).json({ message: 'Could not create lookmax session' });
    }
});
/**
 * POST /api/v1/lookmax/actions
 */
router.post('/actions', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = lookmaxActionSchema.parse(req.body);
        const { data, error } = await (0, db_1.userInsert)('lookmax_actions', userId, {
            session_id: parsed.routineId,
            action: parsed.action,
            notes: parsed.notes
        }).select().single();
        if (error) {
            console.error('[lookmax] Failed to create action:', error.message);
            return res.status(500).json({ message: 'Could not create lookmax action', error: error.message });
        }
        return res.status(201).json({ action: data, status: 'ok' });
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[lookmax] Unexpected error:', err);
        return res.status(500).json({ message: 'Could not create lookmax action' });
    }
});
exports.default = router;
//# sourceMappingURL=lookMax.js.map