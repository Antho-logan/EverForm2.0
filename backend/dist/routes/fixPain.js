"use strict";
/**
 * Fix Pain Routes
 * Pain checks logging and retrieval.
 */
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const db_1 = require("../utils/db");
const router = (0, express_1.Router)();
const painCheckSchema = zod_1.z.object({
    area: zod_1.z.string().min(1),
    severity: zod_1.z.number().int().min(1).max(10),
    description: zod_1.z.string().optional()
});
/**
 * GET /api/v1/fix-pain/recent
 */
router.get('/recent', async (req, res) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await (0, db_1.userSelect)('pain_checks', userId, '*')
            .order('created_at', { ascending: false })
            .limit(3);
        if (error) {
            console.error('[fixPain] Failed to fetch pain checks:', error.message);
            return res.status(500).json({
                message: 'Failed to fetch pain checks',
                error: error.message
            });
        }
        return res.json({ painChecks: data ?? [], status: 'ok' });
    }
    catch (err) {
        console.error('[fixPain] Unexpected error in recent:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});
/**
 * POST /api/v1/fix-pain/assess
 */
router.post('/assess', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = painCheckSchema.parse(req.body);
        const { data, error } = await (0, db_1.userInsert)('pain_checks', userId, {
            area: parsed.area,
            severity: parsed.severity,
            description: parsed.description
        }).select().single();
        if (error) {
            console.error('[fixPain] Failed to create pain check:', error.message);
            return res.status(500).json({
                message: 'Failed to create pain check',
                error: error.message
            });
        }
        return res.status(201).json({ painCheck: data, status: 'ok' });
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[fixPain] Unexpected error on create:', err);
        return res.status(500).json({ message: 'Could not create pain check' });
    }
});
exports.default = router;
//# sourceMappingURL=fixPain.js.map