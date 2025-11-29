"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// Profile routes: CRUD for user profile and onboarding answers.
const express_1 = require("express");
const zod_1 = require("zod");
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
router.get('/', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const { data: profile, error: profileError } = await supabaseClient_1.supabase
            .from('profiles')
            .select('*')
            .eq('user_id', userId)
            .maybeSingle();
        if (profileError) {
            console.error('Failed to fetch profile', profileError);
            return res.status(500).json({ message: 'Could not fetch profile' });
        }
        const { data: answers, error: answersError } = await supabaseClient_1.supabase
            .from('onboarding_answers')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false });
        if (answersError) {
            console.error('Failed to fetch onboarding answers', answersError);
            return res.status(500).json({ message: 'Could not fetch onboarding answers' });
        }
        return res.json({ profile, onboardingAnswers: answers ?? [] });
    }
    catch (err) {
        return next(err);
    }
});
router.put('/', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const parsed = profileSchema.parse(req.body);
        const payload = {
            user_id: userId,
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
        };
        const { data, error } = await supabaseClient_1.supabase
            .from('profiles')
            .upsert(payload, { onConflict: 'user_id' })
            .select()
            .single();
        if (error) {
            console.error('Failed to upsert profile', error);
            return res.status(500).json({ message: 'Could not save profile' });
        }
        return res.json({ profile: data });
    }
    catch (err) {
        return next(err);
    }
});
router.post('/onboarding', async (req, res, next) => {
    try {
        const userId = req.user?.id;
        const parsed = onboardingSchema.parse(req.body);
        const rows = parsed.answers.map((answer) => ({
            user_id: userId,
            question_key: answer.questionKey,
            answer_text: answer.answerText,
            answer_numeric: answer.answerNumeric
        }));
        const { data, error } = await supabaseClient_1.supabase
            .from('onboarding_answers')
            .upsert(rows, { onConflict: 'user_id,question_key' })
            .select();
        if (error) {
            console.error('Failed to save onboarding answers', error);
            return res.status(500).json({ message: 'Could not save onboarding answers' });
        }
        return res.json({ onboardingAnswers: data });
    }
    catch (err) {
        return next(err);
    }
});
exports.default = router;
//# sourceMappingURL=profile.js.map