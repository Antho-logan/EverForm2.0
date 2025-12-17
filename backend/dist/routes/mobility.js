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
const mobilityAssessmentService_1 = require("../services/mobilityAssessmentService");
const mobilityAiService_1 = require("../services/mobilityAiService");
const router = (0, express_1.Router)();
const mobilitySessionSchema = zod_1.z.object({
    routineId: zod_1.z.string(),
    status: zod_1.z.enum(['completed', 'skipped']).default('completed'),
    performedAt: zod_1.z.string().optional()
});
const mobilityTestSchema = zod_1.z.object({
    testId: zod_1.z.string(),
    testName: zod_1.z.string(),
    joint: zod_1.z.enum(['hips', 'thoracic', 'shoulders', 'ankles', 'full_body', 'other']),
    rangeOfMotionScore: zod_1.z.number().min(0).max(5).optional(),
    controlScore: zod_1.z.number().min(0).max(5).optional(),
    pain: zod_1.z.boolean().optional(),
    notes: zod_1.z.string().optional(),
});
const assessmentInputSchema = zod_1.z.object({
    tests: zod_1.z.array(mobilityTestSchema).min(1, 'Provide at least one test result'),
    notes: zod_1.z.string().optional(),
});
const isoDateString = zod_1.z.string().regex(/^\d{4}-\d{2}-\d{2}/);
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
/**
 * POST /api/v1/mobility/assessment/complete
 */
router.post('/assessment/complete', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = assessmentInputSchema.parse(req.body ?? {});
        const assessment = await (0, mobilityAssessmentService_1.createAssessment)(userId, parsed);
        const summary = await (0, mobilityAiService_1.generateAssessmentSummary)(userId, assessment);
        return res.status(201).json(summary);
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[mobility] assessment complete failed', err);
        return res.status(500).json({ message: 'Could not complete mobility assessment' });
    }
});
/**
 * GET /api/v1/mobility/assessment/latest
 */
router.get('/assessment/latest', async (req, res) => {
    try {
        const userId = req.user?.id;
        const { data, error } = await (0, db_1.userSelect)('mobility_profiles', userId, '*')
            .order('updated_at', { ascending: false })
            .limit(1)
            .maybeSingle();
        if (error) {
            console.error('[mobility] latest profile fetch failed', error.message, error.details);
            // Fall back to raw latest assessment if available
            const latestAssessment = await (0, mobilityAssessmentService_1.getLatestAssessment)(userId);
            if (!latestAssessment) {
                return res.json({ status: 'empty', profile: null });
            }
            return res.json({
                status: 'ok',
                profile: {
                    userId,
                    overallScore: latestAssessment.overallScore,
                    hipsScore: latestAssessment.hipsScore,
                    thoracicScore: latestAssessment.thoracicScore,
                    shouldersScore: latestAssessment.shouldersScore,
                    anklesScore: latestAssessment.anklesScore,
                    focusAreas: [],
                    riskNotes: [],
                    lastAssessmentAt: latestAssessment.createdAt,
                },
                aiSummaryText: 'Mobility assessment recorded.',
                focusTags: ['Mobility'],
                recommendedRoutines: [],
                weeklyPlanText: '',
            });
        }
        if (!data) {
            return res.json({ status: 'empty', profile: null });
        }
        const profile = {
            userId,
            overallScore: data.overall_score,
            hipsScore: data.hips_score ?? undefined,
            thoracicScore: data.thoracic_score ?? undefined,
            shouldersScore: data.shoulders_score ?? undefined,
            anklesScore: data.ankles_score ?? undefined,
            focusAreas: data.focus_areas ?? [],
            riskNotes: data.risk_notes ?? [],
            lastAssessmentAt: data.last_assessment_at,
            summaryJson: data.summary_json ?? undefined,
        };
        const summaryJson = data.summary_json;
        const response = summaryJson
            ? { ...summaryJson, profile }
            : {
                profile,
                aiSummaryText: 'Mobility assessment recorded.',
                focusTags: profile.focusAreas ?? [],
                recommendedRoutines: [],
                weeklyPlanText: '',
            };
        return res.json(response);
    }
    catch (err) {
        console.error('[mobility] latest assessment failed', err);
        return res.status(500).json({ message: 'Failed to fetch latest mobility assessment' });
    }
});
/**
 * GET /api/v1/mobility/weekly/focus
 */
router.get('/weekly/focus', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsedFrom = req.query.from ? isoDateString.parse(String(req.query.from)) : undefined;
        const parsedTo = req.query.to ? isoDateString.parse(String(req.query.to)) : undefined;
        const focus = await (0, mobilityAiService_1.getWeeklyFocus)(userId, parsedFrom, parsedTo);
        return res.json(focus);
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[mobility] weekly focus failed', err);
        return res.status(500).json({ message: 'Failed to fetch weekly mobility focus' });
    }
});
// ─────────────────────────────────────────────────────────────────────────────
// Curl Examples (dev)
// ─────────────────────────────────────────────────────────────────────────────
// curl -X POST http://localhost:4000/api/v1/mobility/assessment/complete \
//   -H "Content-Type: application/json" \
//   -H "Authorization: Bearer DEV_USER_TOKEN_IF_USED" \
//   -d '{ "tests": [{ "testId": "freeze_test", "testName": "Freeze Test", "joint": "shoulders", "rangeOfMotionScore": 3, "controlScore": 4, "pain": false }], "notes": "After upper body day" }'
//
// curl -X GET http://localhost:4000/api/v1/mobility/assessment/latest \
//   -H "Authorization: Bearer DEV_USER_TOKEN_IF_USED"
//
// curl -X GET "http://localhost:4000/api/v1/mobility/weekly/focus?from=2025-12-01&to=2025-12-07" \
//   -H "Authorization: Bearer DEV_USER_TOKEN_IF_USED"
exports.default = router;
//# sourceMappingURL=mobility.js.map