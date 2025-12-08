/**
 * AI Breathwork Coach Service
 * - Provides daily suggestion and weekly insight used by /breathwork/ai routes.
 * - Consumes breathwork_sessions data and DeepSeek JSON responses with safe fallbacks.
 */

import axios from 'axios';
import { supabase } from '../config/supabaseClient';
import { env } from '../config/env';
import {
  BreathworkAiTodaySuggestion,
  BreathworkAiWeeklyInsight,
  BreathworkSessionDTO,
} from '../types';

const DEEPSEEK_URL = 'https://api.deepseek.com/v1/chat/completions';

type BreathworkSessionLite = Pick<
  BreathworkSessionDTO,
  'patternId' | 'patternName' | 'durationSeconds' | 'roundsCompleted' | 'longestHoldSeconds' | 'createdAt'
>;

interface BreathworkStats {
  totalSessions: number;
  totalMinutes: number;
  streakDays: number;
  lastPatternId: string | null;
  lastPatternName: string | null;
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, Math.round(value)));
}

async function getRecentBreathworkSessions(userId: string, days: number = 7): Promise<BreathworkSessionLite[]> {
  const sinceIso = new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString();
  const { data, error } = await supabase
    .from('breathwork_sessions')
    .select('*')
    .eq('user_id', userId)
    .gte('completed_at', sinceIso)
    .order('completed_at', { ascending: false })
    .limit(50);

  if (error) {
    console.error('[breathworkAi] failed to fetch sessions', error.message, error.details);
    return [];
  }

  return (data ?? []).map((row: any) => ({
    patternId: row.pattern_id ?? row.technique ?? null,
    patternName: row.pattern_name ?? row.technique ?? 'Breathwork',
    durationSeconds: (row.duration_minutes ?? 0) * 60,
    roundsCompleted: row.rounds_completed ?? 0,
    longestHoldSeconds: row.longest_hold_seconds ?? 0,
    createdAt: row.completed_at ?? row.created_at ?? row.inserted_at ?? new Date().toISOString(),
  }));
}

function computeStreak(dates: string[]): number {
  if (!dates.length) return 0;
  const days = new Set(dates.map((d) => d.slice(0, 10)));
  let streak = 0;
  let cursor = new Date();
  for (;;) {
    const key = cursor.toISOString().slice(0, 10);
    if (days.has(key)) {
      streak += 1;
      cursor = new Date(cursor.getTime() - 24 * 60 * 60 * 1000);
    } else {
      break;
    }
  }
  return streak;
}

function computeStats(sessions: BreathworkSessionLite[]): BreathworkStats {
  const totalMinutes = sessions.reduce((sum, s) => sum + (s.durationSeconds ?? 0) / 60, 0);
  const totalSessions = sessions.length;
  const streakDays = computeStreak(sessions.map((s) => s.createdAt));
  const last = sessions[0];
  return {
    totalSessions,
    totalMinutes: Math.round(totalMinutes),
    streakDays,
    lastPatternId: last?.patternId ?? null,
    lastPatternName: last?.patternName ?? null,
  };
}

function fallbackToday(stats: BreathworkStats): BreathworkAiTodaySuggestion {
  const hasData = stats.totalSessions > 0;
  return {
    suggestedPatternId: hasData ? stats.lastPatternId : null,
    suggestedPatternName: hasData ? stats.lastPatternName ?? 'Box Breathing' : 'Box Breathing',
    suggestedRounds: hasData ? 3 : 2,
    suggestedMinutes: hasData ? 6 : 4,
    suggestionReason: hasData
      ? 'Keeping you consistent with a familiar pattern. Short, calm dose to reinforce habit.'
      : 'Start simple: 2 rounds of box breathing to build the habit and calm the nervous system.',
    focusTags: hasData ? ['Consistency', 'Calm'] : ['Getting Started', 'Calm'],
  };
}

function fallbackWeekly(from: string, to: string, stats: BreathworkStats, trend: 'up' | 'down' | 'flat'): BreathworkAiWeeklyInsight {
  return {
    periodStart: from,
    periodEnd: to,
    totalSessions: stats.totalSessions,
    totalMinutes: stats.totalMinutes,
    streakDays: stats.streakDays,
    trendLabel: trend,
    insightText:
      stats.totalSessions > 0
        ? 'Solid start. Keep doses short and repeatable to lock in the habit.'
        : 'No sessions logged. Begin with 2–3 short sessions this week to build momentum.',
    focusTags: stats.totalSessions > 0 ? ['Consistency', 'Calm'] : ['Getting Started'],
    recommendedFocus: stats.totalSessions > 0 ? '2–3 short evening sessions focused on calm' : 'Log 2 short sessions to start the streak',
  };
}

async function callBreathworkModel(systemPrompt: string, payload: any): Promise<string> {
  if (!env.DEEPSEEK_API_KEY) {
    throw new Error('DEEPSEEK_API_KEY is required for breathwork AI');
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
      timeout: 12000,
    }
  );

  return response.data?.choices?.[0]?.message?.content ?? '';
}

function safeParse<T>(raw: string, fallback: () => T, label: string): T {
  try {
    return JSON.parse(raw) as T;
  } catch (err) {
    console.error(`[breathworkAi] parse failed for ${label}`, raw?.slice(0, 400));
    return fallback();
  }
}

const TODAY_SYSTEM_PROMPT = `You are EverForm, an AI breathwork coach.
You will receive recent breathwork stats. Return STRICT JSON matching:
{
  "suggestedPatternId": string | null,
  "suggestedPatternName": string,
  "suggestedRounds": number,
  "suggestedMinutes": number,
  "suggestionReason": string,
  "focusTags": string[]
}
Rules:
- Keep it habit-focused: consistency, calm, focus. No medical claims or diagnoses.
- Prefer gentle doses (4-10 minutes) and 2-4 rounds unless user already does long sessions.
- If data is sparse, give a beginner-friendly, low-intensity suggestion.
- Be concise (1-2 sentences for reason).`;

export async function getTodaySuggestion(userId: string): Promise<BreathworkAiTodaySuggestion> {
  const sessions = await getRecentBreathworkSessions(userId, 14);
  const stats = computeStats(sessions);
  if (sessions.length === 0) {
    return fallbackToday(stats);
  }

  const payload = { stats, sessions };
  const raw = await callBreathworkModel(TODAY_SYSTEM_PROMPT, payload);
  const result = safeParse<BreathworkAiTodaySuggestion>(raw, () => fallbackToday(stats), 'today suggestion');

  return {
    suggestedPatternId: result.suggestedPatternId ?? stats.lastPatternId ?? null,
    suggestedPatternName: result.suggestedPatternName || stats.lastPatternName || 'Box Breathing',
    suggestedRounds: clamp(result.suggestedRounds || 2, 1, 6),
    suggestedMinutes: clamp(result.suggestedMinutes || 5, 2, 15),
    suggestionReason: result.suggestionReason || 'Short, calm dose to build consistency.',
    focusTags: result.focusTags?.length ? result.focusTags.slice(0, 4) : ['Consistency', 'Calm'],
  };
}

const WEEKLY_SYSTEM_PROMPT = `You are EverForm, an AI breathwork coach.
You will receive breathwork session stats for a week and the previous week.
Return STRICT JSON matching:
{
  "periodStart": string,
  "periodEnd": string,
  "totalSessions": number,
  "totalMinutes": number,
  "streakDays": number,
  "trendLabel": "up" | "down" | "flat",
  "insightText": string,
  "focusTags": string[],
  "recommendedFocus": string
}
Rules:
- Keep insightText to max 2 short paragraphs. No medical claims or diagnoses.
- Focus on habits, calm, focus, and consistency. Encourage short, repeatable doses.
- trendLabel reflects change vs previous period (up/down/flat).`;

export async function getWeeklyInsight(userId: string, from?: string, to?: string): Promise<BreathworkAiWeeklyInsight> {
  const now = new Date();
  const endIso = to ? new Date(to).toISOString() : now.toISOString();
  const startIso = from ? new Date(from).toISOString() : new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString();
  const prevStartIso = new Date(new Date(startIso).getTime() - 7 * 24 * 60 * 60 * 1000).toISOString();
  const prevEndIso = new Date(new Date(startIso).getTime() - 1 * 24 * 60 * 60 * 1000).toISOString();

  const [currentSessions, prevSessions] = await Promise.all([
    supabase
      .from('breathwork_sessions')
      .select('*')
      .eq('user_id', userId)
      .gte('completed_at', startIso)
      .lte('completed_at', endIso)
      .order('completed_at', { ascending: false }),
    supabase
      .from('breathwork_sessions')
      .select('*')
      .eq('user_id', userId)
      .gte('completed_at', prevStartIso)
      .lte('completed_at', prevEndIso)
      .order('completed_at', { ascending: false }),
  ]);

  const mapSessions = (rows: any[] | null | undefined): BreathworkSessionLite[] =>
    (rows ?? []).map((row: any) => ({
      patternId: row.pattern_id ?? row.technique ?? null,
      patternName: row.pattern_name ?? row.technique ?? 'Breathwork',
      durationSeconds: (row.duration_minutes ?? 0) * 60,
      roundsCompleted: row.rounds_completed ?? 0,
      longestHoldSeconds: row.longest_hold_seconds ?? 0,
      createdAt: row.completed_at ?? row.created_at ?? row.inserted_at ?? new Date().toISOString(),
    }));

  const current = mapSessions(currentSessions.data);
  const previous = mapSessions(prevSessions.data);
  const currentStats = computeStats(current);
  const prevStats = computeStats(previous);

  const trend: 'up' | 'down' | 'flat' =
    currentStats.totalSessions > prevStats.totalSessions
      ? 'up'
      : currentStats.totalSessions < prevStats.totalSessions
      ? 'down'
      : 'flat';

  const fallback = () => fallbackWeekly(startIso, endIso, currentStats, trend);

  if (current.length === 0) {
    return fallback();
  }

  const payload = {
    period: { from: startIso, to: endIso },
    stats: currentStats,
    previousStats: prevStats,
    sessions: current,
  };

  const raw = await callBreathworkModel(WEEKLY_SYSTEM_PROMPT, payload);
  const parsed = safeParse<BreathworkAiWeeklyInsight>(raw, fallback, 'weekly insight');

  return {
    periodStart: parsed.periodStart || startIso,
    periodEnd: parsed.periodEnd || endIso,
    totalSessions: parsed.totalSessions ?? currentStats.totalSessions,
    totalMinutes: parsed.totalMinutes ?? currentStats.totalMinutes,
    streakDays: parsed.streakDays ?? currentStats.streakDays,
    trendLabel: parsed.trendLabel ?? trend,
    insightText:
      parsed.insightText ||
      (currentStats.totalSessions > 0
        ? 'Steady work this week. Keep doses short and consistent.'
        : 'Start with 2–3 short sessions this week to build momentum.'),
    focusTags: parsed.focusTags?.length ? parsed.focusTags.slice(0, 4) : ['Consistency', 'Calm'],
    recommendedFocus:
      parsed.recommendedFocus ||
      (currentStats.totalSessions > 0 ? 'Evening wind-down 3x/week' : 'Log 2 short evening sessions'),
  };
}


