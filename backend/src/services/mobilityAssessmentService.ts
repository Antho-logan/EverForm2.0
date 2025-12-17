import { supabase } from '../config/supabaseClient';
import {
  MobilityAssessment,
  MobilityAssessmentInput,
  MobilityJointScores,
  MobilityProfile,
  MobilityTestResult,
} from '../types';
import { userInsert, userSelect, userUpsert } from '../utils/db';

const JOINT_KEYS: (keyof MobilityJointScores)[] = [
  'hipsScore',
  'thoracicScore',
  'shouldersScore',
  'anklesScore',
];

function clampScore(value: number): number {
  if (Number.isNaN(value)) return 0;
  return Math.min(100, Math.max(0, Math.round(value)));
}

function collectScores(tests: MobilityTestResult[], joint: MobilityTestResult['joint']): number[] {
  return tests
    .filter((t) => t.joint === joint)
    .flatMap((t) => [t.rangeOfMotionScore, t.controlScore].filter((v): v is number => typeof v === 'number'));
}

function averageToHundred(values: number[]): number | undefined {
  if (!values.length) return undefined;
  const avg = values.reduce((sum, v) => sum + v, 0) / values.length;
  return clampScore(avg * 20);
}

export function computeJointScores(tests: MobilityTestResult[]): MobilityJointScores {
  return {
    hipsScore: averageToHundred(collectScores(tests, 'hips')),
    thoracicScore: averageToHundred(collectScores(tests, 'thoracic')),
    shouldersScore: averageToHundred(collectScores(tests, 'shoulders')),
    anklesScore: averageToHundred(collectScores(tests, 'ankles')),
  };
}

export function computeOverallScore(joints: MobilityJointScores): number {
  const scores = JOINT_KEYS.map((k) => joints[k]).filter((v): v is number => typeof v === 'number');
  if (!scores.length) return 50;
  const avg = scores.reduce((sum, v) => sum + v, 0) / scores.length;
  return clampScore(avg);
}

function mapRowToAssessment(row: any): MobilityAssessment {
  return {
    id: row.id,
    userId: row.user_id,
    createdAt: row.created_at,
    overallScore: row.overall_score,
    hipsScore: row.hips_score ?? undefined,
    thoracicScore: row.thoracic_score ?? undefined,
    shouldersScore: row.shoulders_score ?? undefined,
    anklesScore: row.ankles_score ?? undefined,
    rawResults: row.raw_results ?? [],
    notes: row.notes ?? undefined,
  };
}

export function buildProfileFromAssessment(
  assessment: MobilityAssessment,
  focusAreas: string[] = [],
  riskNotes: string[] = [],
  summaryJson: Record<string, unknown> | undefined = undefined
): MobilityProfile {
  return {
    userId: assessment.userId,
    overallScore: assessment.overallScore,
    hipsScore: assessment.hipsScore,
    thoracicScore: assessment.thoracicScore,
    shouldersScore: assessment.shouldersScore,
    anklesScore: assessment.anklesScore,
    focusAreas,
    riskNotes,
    lastAssessmentAt: assessment.createdAt,
    summaryJson,
  };
}

export async function createAssessment(
  userId: string,
  input: MobilityAssessmentInput
): Promise<MobilityAssessment> {
  if (!userId) throw new Error('userId is required');
  if (!input.tests?.length) throw new Error('At least one test result is required');

  const jointScores = computeJointScores(input.tests);
  const overallScore = computeOverallScore(jointScores);

  const { data, error } = await userInsert('mobility_assessments', userId, {
    overall_score: overallScore,
    hips_score: jointScores.hipsScore ?? null,
    thoracic_score: jointScores.thoracicScore ?? null,
    shoulders_score: jointScores.shouldersScore ?? null,
    ankles_score: jointScores.anklesScore ?? null,
    raw_results: input.tests,
    notes: input.notes ?? null,
  })
    .select()
    .single();

  if (error) {
    console.error('[mobilityAssessment] insert failed', error.message, error.details);
    throw new Error('Failed to store mobility assessment');
  }

  const assessment = mapRowToAssessment(data);

  // Base profile upsert (AI-enriched fields will be written after AI completes)
  await userUpsert(
    'mobility_profiles',
    userId,
    {
      overall_score: overallScore,
      hips_score: jointScores.hipsScore ?? null,
      thoracic_score: jointScores.thoracicScore ?? null,
      shoulders_score: jointScores.shouldersScore ?? null,
      ankles_score: jointScores.anklesScore ?? null,
      focus_areas: [],
      risk_notes: [],
      last_assessment_at: assessment.createdAt,
      summary_json: {},
      updated_at: new Date().toISOString(),
    },
    'user_id'
  );

  return assessment;
}

export async function getLatestAssessment(userId: string): Promise<MobilityAssessment | null> {
  const { data, error } = await userSelect('mobility_assessments', userId, '*')
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  if (error) {
    console.error('[mobilityAssessment] failed to fetch latest', error.message, error.details);
    return null;
  }
  if (!data) return null;
  return mapRowToAssessment(data);
}

export async function getAssessmentsInRange(
  userId: string,
  from?: string,
  to?: string
): Promise<MobilityAssessment[]> {
  let query = supabase.from('mobility_assessments').select('*').eq('user_id', userId).order('created_at', {
    ascending: false,
  });
  if (from) query = query.gte('created_at', from);
  if (to) query = query.lte('created_at', to);

  const { data, error } = await query;
  if (error) {
    console.error('[mobilityAssessment] range fetch failed', error.message, error.details);
    return [];
  }
  return (data ?? []).map(mapRowToAssessment);
}

