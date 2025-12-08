/**
 * Coach Agent Service
 * 
 * Stub implementations for AI-powered coaching features.
 * Each function is designed to be easily replaced with real LLM calls.
 * 
 * TODO: Replace heuristic implementations with actual LLM calls (DeepSeek/Claude/etc.)
 */

import { supabase } from '../config/supabaseClient';

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

export interface LLMResponse {
  content: string;
  scores?: Record<string, number>;
  metadata?: Record<string, any>;
}

export interface DailySummaryData {
  trainingScore: number;
  nutritionScore: number;
  recoveryScore: number;
  sleepScore: number;
  overallScore: number;
  summaryText: string;
}

export interface WeeklyReportData {
  scores: {
    avgTraining: number;
    avgNutrition: number;
    avgRecovery: number;
    avgSleep: number;
    avgOverall: number;
  };
  focusPoints: string[];
  wins: string;
  risks: string;
}

// ─────────────────────────────────────────────────────────────────────────────
// LLM Abstraction Layer (TODO: Implement real LLM calls)
// ─────────────────────────────────────────────────────────────────────────────

type LLMTask = 'daily_summary' | 'weekly_report' | 'goal_update' | 'recovery_feedback';

/**
 * Placeholder for LLM calls. Replace with actual API integration.
 * 
 * TODO: Replace this with real LLM call to DeepSeek/Claude/GPT-4
 * Example integration:
 *   const response = await axios.post(LLM_API_URL, {
 *     model: 'deepseek-chat',
 *     messages: [{ role: 'system', content: systemPrompt }, { role: 'user', content: JSON.stringify(payload) }],
 *     response_format: { type: 'json_object' }
 *   }, { headers: { Authorization: `Bearer ${env.LLM_API_KEY}` } });
 *   return JSON.parse(response.data.choices[0].message.content);
 */
async function callLLM(task: LLMTask, payload: any): Promise<LLMResponse> {
  console.log(`[coachAgent] LLM stub called for task: ${task}`);
  
  // Return placeholder - in production this would call the real model
  return {
    content: `Placeholder response for ${task}`,
    scores: {},
    metadata: { stubbed: true, task, timestamp: new Date().toISOString() }
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Data Fetchers
// ─────────────────────────────────────────────────────────────────────────────

async function fetchDayData(userId: string, date: string) {
  const [trainingResult, nutritionResult, recoveryResult, sleepResult] = await Promise.all([
    supabase
      .from('training_logs')
      .select('*')
      .eq('user_id', userId)
      .eq('date_performed', date),
    supabase
      .from('nutrition_logs')
      .select('*')
      .eq('user_id', userId)
      .eq('date', date),
    supabase
      .from('recovery_logs')
      .select('*')
      .eq('user_id', userId)
      .eq('date', date),
    supabase
      .from('sleep_logs')
      .select('*')
      .eq('user_id', userId)
      .eq('date', date)
  ]);

  return {
    training: trainingResult.data ?? [],
    nutrition: nutritionResult.data ?? [],
    recovery: recoveryResult.data ?? [],
    sleep: sleepResult.data ?? []
  };
}

async function fetchWeekData(userId: string, startDate: string, endDate: string) {
  const { data: summaries } = await supabase
    .from('daily_summaries')
    .select('*')
    .eq('user_id', userId)
    .gte('date', startDate)
    .lte('date', endDate)
    .order('date', { ascending: true });

  return summaries ?? [];
}

async function fetchUserGoals(userId: string) {
  const { data } = await supabase
    .from('goals')
    .select('*')
    .eq('user_id', userId)
    .maybeSingle();

  return data;
}

async function fetchNutritionTargets(userId: string) {
  const { data } = await supabase
    .from('nutrition_targets')
    .select('*')
    .eq('user_id', userId)
    .maybeSingle();

  return data;
}

// ─────────────────────────────────────────────────────────────────────────────
// Score Calculators (Heuristic Stubs)
// ─────────────────────────────────────────────────────────────────────────────

function calculateTrainingScore(logs: any[]): number {
  if (logs.length === 0) return 0;
  // Basic heuristic: trained = good score, modified by effort
  const avgEffort = logs.reduce((sum, l) => sum + (l.perceived_effort ?? 7), 0) / logs.length;
  return Math.min(100, Math.round(70 + (avgEffort - 5) * 6));
}

function calculateNutritionScore(logs: any[], targets: any): number {
  if (logs.length === 0) return 0;
  if (!targets) return 50; // No targets set, neutral score
  
  const totalProtein = logs.reduce((sum, l) => sum + (l.protein_g ?? 0), 0);
  const proteinRatio = Math.min(1, totalProtein / (targets.protein_g || 150));
  return Math.round(proteinRatio * 100);
}

function calculateRecoveryScore(logs: any[]): number {
  if (logs.length === 0) return 0;
  // More activities = better recovery
  const totalActivities = logs.reduce((sum, l) => sum + (l.activities?.length ?? 0), 0);
  return Math.min(100, 50 + totalActivities * 15);
}

function calculateSleepScore(logs: any[]): number {
  if (logs.length === 0) return 0;
  const log = logs[0];
  // Use provided score or calculate from hours
  if (log.sleep_score) return log.sleep_score;
  const hours = log.hours ?? 0;
  if (hours >= 7 && hours <= 9) return 90;
  if (hours >= 6 && hours <= 10) return 70;
  return 50;
}

function calculateOverallScore(scores: { training: number; nutrition: number; recovery: number; sleep: number }): number {
  const weights = { training: 0.3, nutrition: 0.25, recovery: 0.2, sleep: 0.25 };
  const weighted = 
    scores.training * weights.training +
    scores.nutrition * weights.nutrition +
    scores.recovery * weights.recovery +
    scores.sleep * weights.sleep;
  return Math.round(weighted);
}

function generateSummaryText(scores: DailySummaryData, dayData: any): string {
  const parts: string[] = [];
  
  if (scores.trainingScore > 0) {
    parts.push(`Training completed (effort: ${dayData.training[0]?.perceived_effort ?? 'N/A'}/10).`);
  }
  
  if (scores.nutritionScore >= 80) {
    parts.push('Nutrition on track.');
  } else if (scores.nutritionScore > 0) {
    parts.push('Nutrition logged but below targets.');
  }
  
  if (scores.sleepScore >= 80) {
    parts.push('Great sleep!');
  } else if (scores.sleepScore > 0) {
    parts.push('Sleep could improve.');
  }
  
  if (scores.recoveryScore > 50) {
    const activities = dayData.recovery.flatMap((r: any) => r.activities ?? []);
    if (activities.length > 0) {
      parts.push(`Recovery: ${activities.join(', ')}.`);
    }
  }
  
  // TODO: Replace with LLM-generated personalized summary
  return parts.length > 0 ? parts.join(' ') : 'Log more activities for a complete summary.';
}

// ─────────────────────────────────────────────────────────────────────────────
// Public API
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Generates/updates daily summary for a user.
 * Called after training/nutrition/recovery logs are saved.
 * 
 * TODO: Replace heuristic scoring with LLM analysis for personalized insights.
 */
export async function runDailySummary(userId: string, date: string): Promise<DailySummaryData> {
  console.log(`[coachAgent] Running daily summary for user ${userId} on ${date}`);
  
  // Fetch all data for the day
  const dayData = await fetchDayData(userId, date);
  const nutritionTargets = await fetchNutritionTargets(userId);
  
  // Calculate scores using heuristics (TODO: replace with LLM)
  const trainingScore = calculateTrainingScore(dayData.training);
  const nutritionScore = calculateNutritionScore(dayData.nutrition, nutritionTargets);
  const recoveryScore = calculateRecoveryScore(dayData.recovery);
  const sleepScore = calculateSleepScore(dayData.sleep);
  const overallScore = calculateOverallScore({ training: trainingScore, nutrition: nutritionScore, recovery: recoveryScore, sleep: sleepScore });
  
  const summaryData: DailySummaryData = {
    trainingScore,
    nutritionScore,
    recoveryScore,
    sleepScore,
    overallScore,
    summaryText: generateSummaryText({ trainingScore, nutritionScore, recoveryScore, sleepScore, overallScore, summaryText: '' }, dayData)
  };
  
  // Upsert into daily_summaries
  const { error: summaryError } = await supabase
    .from('daily_summaries')
    .upsert({
      user_id: userId,
      date,
      training_score: summaryData.trainingScore,
      nutrition_score: summaryData.nutritionScore,
      recovery_score: summaryData.recoveryScore,
      sleep_score: summaryData.sleepScore,
      overall_score: summaryData.overallScore,
      summary_text: summaryData.summaryText,
      updated_at: new Date().toISOString()
    }, { onConflict: 'user_id,date' });
  
  if (summaryError) {
    console.error('[coachAgent] Failed to upsert daily summary:', summaryError.message);
  }
  
  // Insert coach message with daily tip
  if (summaryData.overallScore > 0) {
    const tipContent = summaryData.overallScore >= 80
      ? 'Great day! Keep the momentum going tomorrow.'
      : summaryData.overallScore >= 50
      ? 'Solid effort today. Focus on consistency.'
      : 'Tomorrow is a new opportunity. Prioritize sleep and nutrition.';
    
    await supabase.from('coach_messages').insert({
      user_id: userId,
      type: 'daily_tip',
      content: tipContent
    });
  }
  
  return summaryData;
}

/**
 * Generates weekly report analyzing the past 7 days.
 * Designed to be called by a scheduled job.
 * 
 * TODO: Replace with LLM for deep analysis and personalized recommendations.
 */
export async function runWeeklyReport(userId: string, weekStart: string, weekEnd: string): Promise<WeeklyReportData> {
  console.log(`[coachAgent] Running weekly report for user ${userId}: ${weekStart} to ${weekEnd}`);
  
  const summaries = await fetchWeekData(userId, weekStart, weekEnd);
  const goals = await fetchUserGoals(userId);
  
  // Calculate averages
  const avgTraining = summaries.length > 0
    ? Math.round(summaries.reduce((sum, s) => sum + (s.training_score ?? 0), 0) / summaries.length)
    : 0;
  const avgNutrition = summaries.length > 0
    ? Math.round(summaries.reduce((sum, s) => sum + (s.nutrition_score ?? 0), 0) / summaries.length)
    : 0;
  const avgRecovery = summaries.length > 0
    ? Math.round(summaries.reduce((sum, s) => sum + (s.recovery_score ?? 0), 0) / summaries.length)
    : 0;
  const avgSleep = summaries.length > 0
    ? Math.round(summaries.reduce((sum, s) => sum + (s.sleep_score ?? 0), 0) / summaries.length)
    : 0;
  const avgOverall = summaries.length > 0
    ? Math.round(summaries.reduce((sum, s) => sum + (s.overall_score ?? 0), 0) / summaries.length)
    : 0;
  
  // Generate focus points based on lowest scores
  const focusPoints: string[] = [];
  const scoreMap = [
    { name: 'Training consistency', score: avgTraining },
    { name: 'Nutrition quality', score: avgNutrition },
    { name: 'Recovery activities', score: avgRecovery },
    { name: 'Sleep optimization', score: avgSleep }
  ];
  scoreMap.sort((a, b) => a.score - b.score);
  focusPoints.push(...scoreMap.slice(0, 2).map(s => s.name));
  
  // Heuristic wins/risks (TODO: replace with LLM analysis)
  const wins = avgOverall >= 70 
    ? 'Consistent week with good overall scores.' 
    : summaries.length >= 5 
    ? 'Good data logging habit this week.'
    : 'Started tracking this week.';
  
  const risks = avgSleep < 60 
    ? 'Sleep debt may impact recovery and gains.' 
    : avgNutrition < 60
    ? 'Nutrition gaps may slow progress.'
    : 'No major risks identified.';
  
  const reportData: WeeklyReportData = {
    scores: { avgTraining, avgNutrition, avgRecovery, avgSleep, avgOverall },
    focusPoints,
    wins,
    risks
  };
  
  // Upsert weekly report
  const { error: reportError } = await supabase
    .from('weekly_reports')
    .upsert({
      user_id: userId,
      week_start_date: weekStart,
      week_end_date: weekEnd,
      scores: reportData.scores,
      focus_points: reportData.focusPoints,
      wins: reportData.wins,
      risks: reportData.risks
    }, { onConflict: 'user_id,week_start_date' });
  
  if (reportError) {
    console.error('[coachAgent] Failed to upsert weekly report:', reportError.message);
  }
  
  // Insert coach message
  await supabase.from('coach_messages').insert({
    user_id: userId,
    type: 'weekly_report',
    content: `Weekly Summary (${weekStart} - ${weekEnd}): Overall ${avgOverall}%. Focus areas: ${focusPoints.join(', ')}. ${wins}`
  });
  
  return reportData;
}

/**
 * Called when user updates their goals.
 * Triggers plan regeneration or adjustment.
 * 
 * TODO: Use LLM to generate personalized training/nutrition plan based on new goals.
 */
export async function onGoalChanged(userId: string): Promise<void> {
  console.log(`[coachAgent] Goal changed for user ${userId}, preparing to update plans...`);
  
  const goals = await fetchUserGoals(userId);
  
  if (!goals) {
    console.log('[coachAgent] No goals found, skipping plan update');
    return;
  }
  
  // TODO: Replace with LLM call to generate new training plan based on goals
  // Example:
  // const llmResponse = await callLLM('goal_update', { goals, userId });
  // await generateTrainingPlan(userId, llmResponse);
  
  // For now, just insert a coach message acknowledging the change
  const goalText = goals.primary_goal?.replace('_', ' ') ?? 'general fitness';
  await supabase.from('coach_messages').insert({
    user_id: userId,
    type: 'goal_update',
    content: `Goals updated! I'm adjusting your plan for ${goalText}. Training ${goals.preferred_training_days?.length ?? 3}x per week, ${goals.session_length_minutes ?? 60} min sessions.`
  });
  
  console.log(`[coachAgent] Goal update acknowledged for user ${userId}`);
}

/**
 * Generates recovery feedback based on recent activity.
 * 
 * TODO: Use LLM to provide personalized recovery recommendations.
 */
export async function generateRecoveryFeedback(userId: string, date: string): Promise<string> {
  const dayData = await fetchDayData(userId, date);
  
  // Simple heuristic feedback
  if (dayData.training.length > 0 && dayData.recovery.length === 0) {
    return 'You trained today but logged no recovery. Consider adding mobility, stretching, or a cold plunge.';
  }
  
  if (dayData.sleep.length > 0 && (dayData.sleep[0]?.hours ?? 0) < 7) {
    return 'Short sleep logged. Prioritize an earlier bedtime tonight for better recovery.';
  }
  
  if (dayData.recovery.length > 0) {
    const activities = dayData.recovery.flatMap(r => r.activities ?? []);
    return `Great recovery work! ${activities.join(', ')} will help you bounce back faster.`;
  }
  
  return 'Log your recovery activities to get personalized feedback.';
}

