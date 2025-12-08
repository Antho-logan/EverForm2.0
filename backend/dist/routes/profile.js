"use strict";
/**
 * Profile Routes
 * CRUD for user profile and onboarding answers.
 */
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const db_1 = require("../utils/db");
const supabaseClient_1 = require("../config/supabaseClient");
const router = (0, express_1.Router)();
const profileSchema = zod_1.z.object({
    fullName: zod_1.z.string().max(200).optional(),
    email: zod_1.z.string().email().optional(),
    dateOfBirth: zod_1.z.string().optional(),
    gender: zod_1.z.string().optional(),
    heightCm: zod_1.z.number().int().positive().optional(),
    weightKg: zod_1.z.number().positive().optional(),
    activityLevel: zod_1.z.string().optional(),
    primaryGoal: zod_1.z.string().optional(),
    goalType: zod_1.z.string().optional(),
    bodyFat: zod_1.z.number().nonnegative().optional()
});
const onboardingSchema = zod_1.z.object({
    answers: zod_1.z
        .array(zod_1.z.object({
        questionKey: zod_1.z.string().min(1),
        answerText: zod_1.z.string().optional(),
        answerNumeric: zod_1.z.number().optional()
    }))
        .min(1, 'At least one answer is required')
});
// Default profile for fallback reads (not writes)
const DEFAULT_PROFILE = {
    id: 'guest',
    user_id: 'guest',
    full_name: 'Guest',
    email: null,
    date_of_birth: null,
    gender: null,
    height_cm: null,
    weight_kg: null,
    activity_level: null,
    primary_goal: null,
    goal_type: null,
    body_fat: null,
    created_at: new Date().toISOString()
};
/**
 * GET /api/v1/profile
 */
router.get('/', async (req, res) => {
    try {
        const userId = req.user?.id;
        const [profileResult, answersResult] = await Promise.all([
            (0, db_1.userSelect)('profiles', userId, '*').maybeSingle(),
            (0, db_1.userSelect)('onboarding_answers', userId, '*').order('created_at', { ascending: false })
        ]);
        const profile = profileResult.data ?? DEFAULT_PROFILE;
        const answers = answersResult.data ?? [];
        const status = profileResult.data ? 'ok' : 'fallback';
        return res.json({ profile, onboardingAnswers: answers, status });
    }
    catch (err) {
        console.error('[profile] Unexpected error:', err);
        return res.json({ profile: DEFAULT_PROFILE, onboardingAnswers: [], status: 'fallback' });
    }
});
/**
 * PUT /api/v1/profile
 */
router.put('/', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = profileSchema.parse(req.body);
        const { data, error } = await (0, db_1.userUpsert)('profiles', userId, {
            full_name: parsed.fullName,
            email: parsed.email,
            date_of_birth: parsed.dateOfBirth,
            gender: parsed.gender,
            height_cm: parsed.heightCm,
            weight_kg: parsed.weightKg,
            activity_level: parsed.activityLevel,
            primary_goal: parsed.primaryGoal,
            goal_type: parsed.goalType,
            body_fat: parsed.bodyFat
        }).select().single();
        if (error) {
            console.error('[profile] Failed to upsert profile:', error.message);
            return res.status(500).json({ message: 'Failed to save profile', error: error.message });
        }
        return res.json({ profile: data, status: 'ok' });
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[profile] Unexpected error on PUT:', err);
        return res.status(500).json({ message: 'Could not save profile' });
    }
});
/**
 * POST /api/v1/profile/onboarding
 */
router.post('/onboarding', async (req, res) => {
    try {
        const userId = req.user?.id;
        const parsed = onboardingSchema.parse(req.body);
        const rows = parsed.answers.map((answer) => ({
            user_id: userId,
            question_key: answer.questionKey,
            answer_text: answer.answerText,
            answer_numeric: answer.answerNumeric
        }));
        // Bulk upsert - need raw supabase for this
        const { data, error } = await supabaseClient_1.supabase
            .from('onboarding_answers')
            .upsert(rows, { onConflict: 'user_id,question_key' })
            .select();
        if (error) {
            console.error('[profile] Failed to save onboarding answers:', error.message);
            return res.status(500).json({ message: 'Failed to save onboarding answers', error: error.message });
        }
        return res.json({ onboardingAnswers: data, status: 'ok' });
    }
    catch (err) {
        if (err instanceof zod_1.z.ZodError) {
            return res.status(400).json({ message: 'Validation failed', issues: err.issues });
        }
        console.error('[profile] Unexpected error on onboarding:', err);
        return res.status(500).json({ message: 'Could not save onboarding answers' });
    }
});
exports.default = router;
//# sourceMappingURL=profile.js.map