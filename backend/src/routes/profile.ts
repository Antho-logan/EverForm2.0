/**
 * Profile Routes
 * CRUD for user profile and onboarding answers.
 */

import { Router } from 'express';
import { z } from 'zod';
import { AuthenticatedRequest } from '../types';
import { userSelect, userUpsert } from '../utils/db';
import { supabase } from '../config/supabaseClient';

const router = Router();

const profileSchema = z.object({
  fullName: z.string().max(200).optional(),
  email: z.string().email().optional(),
  dateOfBirth: z.string().optional(),
  gender: z.string().optional(),
  heightCm: z.number().int().positive().optional(),
  weightKg: z.number().positive().optional(),
  activityLevel: z.string().optional(),
  primaryGoal: z.string().optional(),
  goalType: z.string().optional(),
  bodyFat: z.number().nonnegative().optional()
});

const onboardingSchema = z.object({
  answers: z
    .array(
      z.object({
        questionKey: z.string().min(1),
        answerText: z.string().optional(),
        answerNumeric: z.number().optional()
      })
    )
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
router.get('/', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;

    const [profileResult, answersResult] = await Promise.all([
      userSelect('profiles', userId, '*').maybeSingle(),
      userSelect('onboarding_answers', userId, '*').order('created_at', { ascending: false })
    ]);

    const profile = profileResult.data ?? DEFAULT_PROFILE;
    const answers = answersResult.data ?? [];
    const status = profileResult.data ? 'ok' : 'fallback';

    return res.json({ profile, onboardingAnswers: answers, status });
  } catch (err) {
    console.error('[profile] Unexpected error:', err);
    return res.json({ profile: DEFAULT_PROFILE, onboardingAnswers: [], status: 'fallback' });
  }
});

/**
 * PUT /api/v1/profile
 */
router.put('/', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;
    const parsed = profileSchema.parse(req.body);

    const { data, error } = await userUpsert('profiles', userId, {
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
  } catch (err) {
    if (err instanceof z.ZodError) {
      return res.status(400).json({ message: 'Validation failed', issues: err.issues });
    }
    console.error('[profile] Unexpected error on PUT:', err);
    return res.status(500).json({ message: 'Could not save profile' });
  }
});

/**
 * POST /api/v1/profile/onboarding
 */
router.post('/onboarding', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.id as string;
    const parsed = onboardingSchema.parse(req.body);

    const rows = parsed.answers.map((answer) => ({
      user_id: userId,
      question_key: answer.questionKey,
      answer_text: answer.answerText,
      answer_numeric: answer.answerNumeric
    }));

    // Bulk upsert - need raw supabase for this
    const { data, error } = await supabase
      .from('onboarding_answers')
      .upsert(rows, { onConflict: 'user_id,question_key' })
      .select();

    if (error) {
      console.error('[profile] Failed to save onboarding answers:', error.message);
      return res.status(500).json({ message: 'Failed to save onboarding answers', error: error.message });
    }

    return res.json({ onboardingAnswers: data, status: 'ok' });
  } catch (err) {
    if (err instanceof z.ZodError) {
      return res.status(400).json({ message: 'Validation failed', issues: err.issues });
    }
    console.error('[profile] Unexpected error on onboarding:', err);
    return res.status(500).json({ message: 'Could not save onboarding answers' });
  }
});

export default router;
