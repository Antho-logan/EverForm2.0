import axios from 'axios';
import { env } from '../config/env';
import {
  DailyNutritionInsights,
  DailyNutritionSummary,
  NutritionProfile,
  SmartDayPlan,
} from '../types';
import { getOrCreateDefaultNutritionProfile } from './nutritionProfileService';
import { getDailyNutritionSummary } from './nutritionSummaryService';

const DEEPSEEK_URL = 'https://api.deepseek.com/v1/chat/completions';

const INSIGHTS_SYSTEM_PROMPT = `You are EverForm, an evidence-based sports nutritionist and biohacking coach.
You receive structured JSON with user goal, diet type, constraints, daily macro targets, and today's intake.
Output concise daily nutrition insights focused on performance, aesthetics, and general health. Avoid medical claims.
Return strict JSON matching:
{
  "headline": string,
  "summary": string,
  "actions": [{ "label": string, "detail": string }],
  "micronutrientInsights": [{ "label": string, "detail": string }]
}
Rules:
- 2-4 actionable items in actions, practical food/behavior suggestions.
- Micronutrient insights optional (0-3); only include if meaningful.
- Respect dietType and constraints; never suggest restricted foods.
- Keep tone concise and non-clinical; no disease treatment or diagnoses.`;

const PLAN_SYSTEM_PROMPT = `You are EverForm, an evidence-based sports nutritionist and biohacking coach.
You receive structured JSON with user goal, diet type, constraints, daily macro targets, and today's intake.
Create 1-3 meals/snacks to close macro gaps for the rest of the day while respecting constraints.
Return strict JSON matching:
{
  "date": string,
  "remaining": { "kcal": number, "proteinG": number, "carbsG": number, "fatG": number },
  "meals": [
    {
      "slot": "breakfast" | "lunch" | "dinner" | "snack" | "any",
      "name": string,
      "macros": { "kcal": number, "proteinG": number, "carbsG": number, "fatG": number },
      "difficulty": "easy" | "moderate" | "hard",
      "prepTimeMinutes": number,
      "ingredients": string[],
      "notes": string
    }
  ]
}
Rules:
- Tailor portions to close remaining macros; do not overshoot by more than ~15%.
- Respect dietType and constraints; avoid restricted items.
- Keep difficulty mostly 'easy' or 'moderate'; simple prep guidance.`;

async function callNutritionModel(systemPrompt: string, payload: any): Promise<string> {
  if (!env.DEEPSEEK_API_KEY) {
    throw new Error('DEEPSEEK_API_KEY is required for nutrition AI services');
  }

  const response = await axios.post(
    DEEPSEEK_URL,
    {
      model: 'deepseek-chat',
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: JSON.stringify(payload) },
      ],
      response_format: { type: 'json_object' },
    },
    {
      headers: {
        Authorization: `Bearer ${env.DEEPSEEK_API_KEY}`,
      },
      timeout: 15000,
    }
  );

  return response.data?.choices?.[0]?.message?.content ?? '';
}

function buildPayload(profile: NutritionProfile, summary: DailyNutritionSummary) {
  return {
    profile: {
      goal: profile.goal,
      dietType: profile.dietType,
      constraints: profile.constraints,
      biohackerFlags: profile.biohackerFlags ?? {},
      targets: {
        kcal: profile.calorieTarget,
        proteinG: profile.proteinTargetG,
        carbsG: profile.carbTargetG,
        fatG: profile.fatTargetG,
      },
    },
    summary: {
      date: summary.date,
      consumed: {
        kcal: summary.energy.consumed,
        proteinG: summary.protein.consumed,
        carbsG: summary.carbs.consumed,
        fatG: summary.fat.consumed,
      },
      remaining: {
        kcal: summary.energy.remaining,
        proteinG: summary.protein.remaining,
        carbsG: summary.carbs.remaining,
        fatG: summary.fat.remaining,
      },
      micros: summary.micros,
    },
  };
}

function parseJsonResponse<T>(raw: string, context: string): T {
  try {
    return JSON.parse(raw) as T;
  } catch (err) {
    console.error(`[nutritionAi] Failed to parse ${context} response`, raw?.slice(0, 300));
    throw new Error(`Failed to generate nutrition ${context}`);
  }
}

export async function generateDailyNutritionInsights(userId: string, date: string) {
  const profile = await getOrCreateDefaultNutritionProfile(userId);
  const summary = await getDailyNutritionSummary(userId, date);
  const payload = buildPayload(profile, summary);

  const raw = await callNutritionModel(INSIGHTS_SYSTEM_PROMPT, payload);
  const insights = parseJsonResponse<DailyNutritionInsights>(raw, 'insights');

  return { profile, summary, insights };
}

export async function generateSmartDayPlan(userId: string, date: string) {
  const profile = await getOrCreateDefaultNutritionProfile(userId);
  const summary = await getDailyNutritionSummary(userId, date);
  const payload = buildPayload(profile, summary);

  const raw = await callNutritionModel(PLAN_SYSTEM_PROMPT, payload);
  const plan = parseJsonResponse<SmartDayPlan>(raw, 'plan');

  // Ensure remaining mirrors summary to keep clients consistent
  plan.remaining = {
    kcal: summary.energy.remaining,
    proteinG: summary.protein.remaining,
    carbsG: summary.carbs.remaining,
    fatG: summary.fat.remaining,
  };
  plan.date = summary.date;

  return { profile, summary, plan };
}

