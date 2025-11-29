// Profile routes: CRUD for user profile and onboarding answers.
import { Router } from 'express';
import { z } from 'zod';
import { supabase } from '../config/supabaseClient';
import { AuthenticatedRequest } from '../types';

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

router.get('/', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;

    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();

    if (profileError) {
      console.error('Failed to fetch profile', profileError);
      return res.status(500).json({ message: 'Could not fetch profile' });
    }

    const { data: answers, error: answersError } = await supabase
      .from('onboarding_answers')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (answersError) {
      console.error('Failed to fetch onboarding answers', answersError);
      return res.status(500).json({ message: 'Could not fetch onboarding answers' });
    }

    return res.json({ profile, onboardingAnswers: answers ?? [] });
  } catch (err) {
    return next(err);
  }
});

router.put('/', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
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

    const { data, error } = await supabase
      .from('profiles')
      .upsert(payload, { onConflict: 'user_id' })
      .select()
      .single();

    if (error) {
      console.error('Failed to upsert profile', error);
      return res.status(500).json({ message: 'Could not save profile' });
    }

    return res.json({ profile: data });
  } catch (err) {
    return next(err);
  }
});

router.post('/onboarding', async (req: AuthenticatedRequest, res, next) => {
  try {
    const userId = req.user?.id as string;
    const parsed = onboardingSchema.parse(req.body);

    const rows = parsed.answers.map((answer) => ({
      user_id: userId,
      question_key: answer.questionKey,
      answer_text: answer.answerText,
      answer_numeric: answer.answerNumeric
    }));

    const { data, error } = await supabase
      .from('onboarding_answers')
      .upsert(rows, { onConflict: 'user_id,question_key' })
      .select();

    if (error) {
      console.error('Failed to save onboarding answers', error);
      return res.status(500).json({ message: 'Could not save onboarding answers' });
    }

    return res.json({ onboardingAnswers: data });
  } catch (err) {
    return next(err);
  }
});

export default router;
