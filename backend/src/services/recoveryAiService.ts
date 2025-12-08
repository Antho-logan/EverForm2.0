import axios from 'axios';
import { env } from '../config/env';
import {
  DailyRecoveryPlan,
  RecoveryAiContext,
  RecoveryInsight,
} from '../types';

const DEEPSEEK_URL = 'https://api.deepseek.com/v1/chat/completions';

const INSIGHTS_SYSTEM_PROMPT = `You are EverForm, a sports sleep and recovery coach.
You receive structured JSON with a user's recovery profile and light metrics.
Return strict JSON matching:
{
  "headline": string,
  "summary": string,
  "recoveryScore": number,
  "sleepConsistency": number,
  "nervousSystemLoad": "low" | "medium" | "high",
  "keyIssues": string[],
  "todayFocusTags": string[]
}
Rules:
- Be concise, realistic, non-medical. No diagnoses.
- If metrics are missing, infer reasonable defaults and still return numbers.
- Keep keyIssues and todayFocusTags short and actionable.`;

const PLAN_SYSTEM_PROMPT = `You are EverForm, a sports sleep and recovery coach.
You receive structured JSON with a user's recovery profile, timezone, and optional metrics.
Create a structured recovery plan for the target date.
Return strict JSON matching:
{
  "date": string,
  "headline": string,
  "planType": "nightly" | "reset" | "maintenance",
  "steps": [
    { "title": string, "description": string, "relativeMinutes": number | null }
  ]
}
Rules:
- 4-8 steps, short, realistic, and safe. No medical advice.
- relativeMinutes: negative numbers mean minutes before bedtime; allow null if not applicable.
- Tailor to goal and constraints; if data is missing, provide sensible defaults.`;

async function callRecoveryModel(systemPrompt: string, payload: any): Promise<string> {
  if (!env.DEEPSEEK_API_KEY) {
    throw new Error('DEEPSEEK_API_KEY is required for recovery AI services');
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
      headers: { Authorization: `Bearer ${env.DEEPSEEK_API_KEY}` },
      timeout: 15000,
    }
  );

  return response.data?.choices?.[0]?.message?.content ?? '';
}

function parseJsonResponse<T>(raw: string, context: string): T {
  try {
    return JSON.parse(raw) as T;
  } catch (err) {
    console.error(`[recoveryAi] Failed to parse ${context} response`, raw?.slice(0, 400));
    throw new Error(`Failed to generate recovery ${context}`);
  }
}

export async function getTodayRecoveryInsights(context: RecoveryAiContext): Promise<RecoveryInsight> {
  const payload = {
    profile: context.profile,
    today: context.today,
    recentHistory: context.recentHistory,
  };

  const raw = await callRecoveryModel(INSIGHTS_SYSTEM_PROMPT, payload);
  return parseJsonResponse<RecoveryInsight>(raw, 'insights');
}

export async function getSmartRecoveryPlanForDay(
  context: RecoveryAiContext & { targetDate: string }
): Promise<DailyRecoveryPlan> {
  const payload = {
    date: context.targetDate,
    profile: context.profile,
    today: context.today,
    recentHistory: context.recentHistory,
  };

  const raw = await callRecoveryModel(PLAN_SYSTEM_PROMPT, payload);
  return parseJsonResponse<DailyRecoveryPlan>(raw, 'plan');
}

