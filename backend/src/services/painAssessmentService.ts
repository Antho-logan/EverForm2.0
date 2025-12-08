import {
  PainAssessmentInput,
  PainAssessmentRecord,
  PainBodyRegion,
  PainSide,
  PainTriageLevel,
} from '../types';
import { userInsert, userSelect } from '../utils/db';

const sideOptionsByRegion: Record<PainBodyRegion, PainSide[]> = {
  neck: ['left', 'right', 'both', 'center'],
  upper_back: ['left', 'right', 'both', 'center'],
  lower_back: ['left', 'right', 'both', 'center'],
  shoulder: ['left', 'right', 'both'],
  hip: ['left', 'right', 'both'],
  knee: ['left', 'right', 'both'],
  ankle: ['left', 'right', 'both'],
  elbow: ['left', 'right', 'both'],
  wrist: ['left', 'right', 'both'],
  hand: ['left', 'right', 'both'],
  foot: ['left', 'right', 'both'],
};

function normalizeSide(region: PainBodyRegion, side: PainSide): PainSide {
  const allowed = sideOptionsByRegion[region] ?? [];
  return allowed.includes(side) ? side : 'unspecified';
}

function sanitizeStringArray(values: string[] | undefined | null): string[] {
  if (!values) return [];
  const cleaned = values
    .map((v) => (v ?? '').toString().trim())
    .filter((v) => v.length > 0);
  return Array.from(new Set(cleaned));
}

function clampIntensity(value: number): number {
  if (Number.isNaN(value)) return 0;
  return Math.min(10, Math.max(0, Math.round(value)));
}

function mapRowToRecord(row: any): PainAssessmentRecord {
  return {
    id: row.id,
    userId: row.user_id,
    createdAt: row.created_at,
    bodyRegion: row.body_region,
    side: row.side,
    painDuration: row.pain_duration,
    painIntensity: row.pain_intensity,
    painCharacter: row.pain_character ?? [],
    aggravatingFactors: row.aggravating_factors ?? [],
    relievingFactors: row.relieving_factors ?? [],
    activityContext: row.activity_context ?? [],
    redFlags: row.red_flags ?? [],
    functionalLimitations: row.functional_limitations ?? [],
    notes: row.notes ?? undefined,
    photoUrl: row.photo_url ?? undefined,
    hasRedFlags: row.has_red_flags ?? false,
    triageLevel: row.triage_level as PainTriageLevel,
    aiSummaryJson: row.ai_summary_json ?? undefined,
    aiVersion: row.ai_version ?? 'v1',
  };
}

export async function createPainAssessment(
  userId: string,
  input: PainAssessmentInput
): Promise<PainAssessmentRecord> {
  if (!userId) throw new Error('userId is required');

  try {
    const side = normalizeSide(input.bodyRegion, input.side);
    const painCharacter = sanitizeStringArray(input.painCharacter);
    const aggravatingFactors = sanitizeStringArray(input.aggravatingFactors);
    const relievingFactors = sanitizeStringArray(input.relievingFactors);
    const activityContext = sanitizeStringArray(input.activityContext);
    const redFlags = sanitizeStringArray(input.redFlags);
    const functionalLimitations = sanitizeStringArray(input.functionalLimitations);

    const payload = {
      body_region: input.bodyRegion,
      side,
      pain_duration: input.painDuration,
      pain_intensity: clampIntensity(input.painIntensity),
      pain_character: painCharacter,
      aggravating_factors: aggravatingFactors,
      relieving_factors: relievingFactors,
      activity_context: activityContext,
      red_flags: redFlags,
      has_red_flags: redFlags.length > 0,
      functional_limitations: functionalLimitations,
      notes: input.notes?.trim() || null,
      photo_url: input.photoUrl ?? null,
      triage_level: 'self_manage',
      ai_version: 'v1',
    };

    const { data, error } = await userInsert('pain_assessments', userId, payload).select().single();
    if (error) {
      console.error('[painAssessment] insert failed', error.message, error.details);
      throw new Error('Failed to store pain assessment');
    }

    return mapRowToRecord(data);
  } catch (err) {
    console.error('createPainAssessment failed', err);
    throw err;
  }
}

export async function getLatestPainAssessment(userId: string): Promise<PainAssessmentRecord | null> {
  const { data, error } = await userSelect('pain_assessments', userId, '*')
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  if (error) {
    console.error('[painAssessment] latest fetch failed', error.message, error.details);
    return null;
  }
  if (!data) return null;
  return mapRowToRecord(data);
}

