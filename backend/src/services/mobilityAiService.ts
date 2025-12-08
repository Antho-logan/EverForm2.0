import axios from 'axios';
import { env } from '../config/env';
import {
  MobilityAssessment,
  MobilityAssessmentSummary,
  MobilityProfile,
  MobilityWeeklyFocus,
} from '../types';
import { supabase } from '../config/supabaseClient';
import {
  buildProfileFromAssessment,
  getAssessmentsInRange,
} from './mobilityAssessmentService';
import { userUpsert } from '../utils/db';

const DEEPSEEK_URL = 'https://api.deepseek.com/v1/chat/completions';

async function callMobilityModel(systemPrompt: string, payload: any): Promise<string> {
  if (!env.DEEPSEEK_API_KEY) {
    throw new Error('DEEPSEEK_API_KEY is required for mobility AI services');
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

function safeParseJson<T>(raw: string, fallback: () => T, label: string): T {
  try {
    return JSON.parse(raw) as T;
  } catch (err) {
    console.error(`[mobilityAi] Failed to parse ${label}:`, raw?.slice(0, 400));
    return fallback();
  }
}

async function fetchRecentSessions(userId: string, fromIso?: string) {
  let query = supabase
    .from('mobility_sessions')
    .select('id, performed_at, status, mobility_routines(name, target_areas, duration_minutes)')
    .eq('user_id', userId)
    .order('performed_at', { ascending: false })
    .limit(30);
  if (fromIso) {
    query = query.gte('performed_at', fromIso);
  }
  const { data, error } = await query;
  if (error) {
    console.error('[mobilityAi] failed to fetch recent sessions', error.message, error.details);
    return [];
  }
  return data ?? [];
}

const ASSESSMENT_SYSTEM_PROMPT = `You are EverForm, an athletic mobility coach.
You will receive a user's mobility assessment (per-joint 0-100 scores) plus raw test results and recent routine history.
Return STRICT JSON ONLY with shape:
{
  "profile": {
    "userId": string,
    "overallScore": number,
    "hipsScore": number | null,
    "thoracicScore": number | null,
    "shouldersScore": number | null,
    "anklesScore": number | null,
    "focusAreas": string[],
    "riskNotes": string[],
    "lastAssessmentAt": string
  },
  "aiSummaryText": string,
  "focusTags": string[],
  "recommendedRoutines": [
    { "id": string, "name": string, "priority": "high" | "medium" | "low", "frequencyPerWeek": number | null }
  ],
  "weeklyPlanText": string
}
Rules:
- Be concise, realistic, non-medical.
- Focus areas and tags should map to joints or movement patterns (e.g. "Hips & Thoracic", "Ankles Stability").
- If data is limited, return safe defaults but keep the JSON shape.`;

export async function generateAssessmentSummary(
  userId: string,
  assessment: MobilityAssessment
): Promise<MobilityAssessmentSummary> {
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
  const recentSessions = await fetchRecentSessions(userId, thirtyDaysAgo);

  const payload = {
    assessment,
    recentSessions: recentSessions.map((s) => ({
      performedAt: s.performed_at,
      status: s.status,
      routine: s.mobility_routines,
    })),
  };

  const fallback = (): MobilityAssessmentSummary => ({
    profile: buildProfileFromAssessment(assessment, ['Mobility'], [], undefined),
    aiSummaryText: 'Mobility assessment recorded. Aim for 2-3 targeted sessions this week.',
    focusTags: ['Mobility'],
    recommendedRoutines: [],
    weeklyPlanText: 'Keep sessions short (10-15m) focusing on hips and thoracic mobility.',
  });

  const raw = await callMobilityModel(ASSESSMENT_SYSTEM_PROMPT, payload);
  const summary = safeParseJson<MobilityAssessmentSummary>(raw, fallback, 'assessment summary');

  // Ensure profile is populated with core metrics
  const profile: MobilityProfile = summary.profile
    ? {
        ...summary.profile,
        userId,
        overallScore: summary.profile.overallScore ?? assessment.overallScore,
        hipsScore: summary.profile.hipsScore ?? assessment.hipsScore,
        thoracicScore: summary.profile.thoracicScore ?? assessment.thoracicScore,
        shouldersScore: summary.profile.shouldersScore ?? assessment.shouldersScore,
        anklesScore: summary.profile.anklesScore ?? assessment.anklesScore,
        focusAreas: summary.profile.focusAreas ?? summary.focusTags ?? [],
        riskNotes: summary.profile.riskNotes ?? [],
        lastAssessmentAt: summary.profile.lastAssessmentAt ?? assessment.createdAt,
        summaryJson: undefined,
      }
    : buildProfileFromAssessment(assessment, summary.focusTags ?? [], [], undefined);

  const upsertPayload = {
    overall_score: profile.overallScore,
    hips_score: profile.hipsScore ?? null,
    thoracic_score: profile.thoracicScore ?? null,
    shoulders_score: profile.shouldersScore ?? null,
    ankles_score: profile.anklesScore ?? null,
    focus_areas: profile.focusAreas ?? [],
    risk_notes: profile.riskNotes ?? [],
    last_assessment_at: profile.lastAssessmentAt,
    summary_json: { ...summary, profile: { ...profile, summaryJson: undefined } },
    updated_at: new Date().toISOString(),
  };

  await userUpsert('mobility_profiles', userId, upsertPayload, 'user_id').select().maybeSingle();

  return { ...summary, profile };
}

const WEEKLY_SYSTEM_PROMPT = `You are EverForm, an athletic mobility coach.
You will receive recent mobility assessments (0-100 scores) and session history for a user.
Return STRICT JSON ONLY with shape:
{
  "averageScore": number | null,
  "fromDate": string,
  "toDate": string,
  "focusTitle": string,
  "focusTags": string[],
  "warnings": string[],
  "coachInsight": string
}
Rules:
- Keep language concise (1-2 sentences for coachInsight).
- Warnings should be short bullet-style phrases.
- Focus tags should map to joints or patterns (e.g. "Hips & Thoracic", "Ankles", "Posture").`;

export async function getWeeklyFocus(
  userId: string,
  fromDate?: string,
  toDate?: string
): Promise<MobilityWeeklyFocus> {
  const now = new Date();
  const isoToday = now.toISOString();
  const defaultFrom = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString();

  const rangeFrom = fromDate ?? defaultFrom;
  const rangeTo = toDate ?? isoToday;

  const assessments = await getAssessmentsInRange(userId, rangeFrom, rangeTo);
  const sessions = await fetchRecentSessions(userId, rangeFrom);

  const averageScore =
    assessments.length > 0
      ? Math.round(
          assessments.reduce((sum, a) => sum + (a.overallScore ?? 0), 0) / assessments.length
        )
      : undefined;

  const payload = {
    dateRange: { from: rangeFrom, to: rangeTo },
    assessments,
    sessions,
    stats: {
      assessmentCount: assessments.length,
      sessionCount: sessions.length,
      averageScore: averageScore ?? null,
    },
  };

  const fallback = (): MobilityWeeklyFocus => ({
    averageScore: averageScore,
    fromDate: rangeFrom,
    toDate: rangeTo,
    focusTitle: 'Build mobility consistency',
    focusTags: ['Mobility'],
    warnings: sessions.length ? [] : ['No mobility sessions logged'],
    coachInsight: 'Aim for 2-3 short mobility sessions focusing on hips and thoracic rotation.',
  });

  const raw = await callMobilityModel(WEEKLY_SYSTEM_PROMPT, payload);
  const focus = safeParseJson<MobilityWeeklyFocus>(raw, fallback, 'weekly focus');

  return {
    ...focus,
    averageScore: focus.averageScore ?? averageScore,
    fromDate: focus.fromDate ?? rangeFrom,
    toDate: focus.toDate ?? rangeTo,
  };
}

