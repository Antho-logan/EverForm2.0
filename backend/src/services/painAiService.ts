import axios from 'axios';
import { env } from '../config/env';
import { supabase } from '../config/supabaseClient';
import { PainAiPlan, PainAssessmentRecord, PainTriageLevel } from '../types';
import { PainPhotoFindings } from './painPhotoService';

const DEEPSEEK_URL = 'https://api.deepseek.com/v1/chat/completions';

function hasCriticalFlags(redFlags: string[], textBuckets: string[]): boolean {
  const seriousKeywords = ['numbness', 'tingling', 'bladder', 'bowel', 'incontinence', 'severe trauma', 'fever', 'night pain', 'unexplained weight loss', 'weakness'];
  const haystack = [...redFlags, ...textBuckets].join(' ').toLowerCase();
  return seriousKeywords.some((k) => haystack.includes(k));
}

function fallbackTriage(assessment: PainAssessmentRecord, critical: boolean): PainTriageLevel {
  if (critical || assessment.hasRedFlags) return 'see_doctor_soon';
  if (assessment.painIntensity >= 8 || (assessment.painDuration === 'chronic' && (assessment.functionalLimitations?.length ?? 0) > 0)) {
    return 'caution';
  }
  return 'self_manage';
}

function fallbackPlan(assessment: PainAssessmentRecord, photoFindings: PainPhotoFindings | null, triage: PainTriageLevel): PainAiPlan {
  return {
    triageLevel: triage,
    showDoctorBanner: triage !== 'self_manage',
    doctorBannerTitle: triage === 'see_doctor_soon' ? 'Consider seeing a clinician' : triage === 'caution' ? 'Monitor symptoms' : undefined,
    doctorBannerBody:
      triage === 'see_doctor_soon'
        ? 'Your answers suggest possible red flags. Please seek medical evaluation.'
        : triage === 'caution'
        ? 'If symptoms worsen or persist, consult a healthcare professional.'
        : undefined,
    riskReasons: assessment.redFlags ?? [],
    summaryTitle: 'Movement-first recovery plan',
    summaryBody: 'Use gentle mobility, light activation, and load management. Avoid provocative positions and monitor symptoms.',
    likelyTissues: ['muscle / fascia', 'joint irritation'],
    aggravatingThemes: assessment.aggravatingFactors ?? [],
    warmupAndMobility: [
      { title: 'Breathing + gentle mobility', description: '2-3 minutes diaphragmatic breathing, slow pain-free arcs.', durationMinutes: 5 },
      { title: 'Tissue prep', description: 'Light self-massage or foam roll 2-3 minutes if comfortable.' },
    ],
    strengthAndActivation: [
      { title: 'Isometric holds', description: 'Light effort, mid-range, 3-4 holds of 20-30s.' },
      { title: 'Low-load activation', description: '2 sets of easy reps in pain-free range to promote circulation.' },
    ],
    recoveryAdvice: [
      { title: 'Load management', description: 'Keep moving but avoid sharp pain. Gradually reintroduce load.' },
      { title: 'Pacing & breaks', description: 'Micro-breaks every hour; change positions often.' },
      { title: 'Sleep & recovery', description: 'Prioritize sleep; gentle heat/ice if it subjectively helps.' },
      ...(photoFindings ? [{ title: 'Photo note', description: photoFindings.summaryText }] : []),
    ],
    safetyNotes: [
      'If new numbness, weakness, or bladder/bowel changes occur, seek urgent care.',
      'Stop activities that trigger sharp or worsening pain.',
    ],
    disclaimer: 'Educational only and not a medical diagnosis. Consult a healthcare professional for medical concerns.',
    createdAt: new Date().toISOString(),
  };
}

async function callDeepSeek(systemPrompt: string, payload: any): Promise<string> {
  if (!env.DEEPSEEK_API_KEY) {
    throw new Error('DEEPSEEK_API_KEY is required for FixPain AI');
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

function safeParsePlan(raw: string, fallback: () => PainAiPlan): PainAiPlan {
  try {
    return JSON.parse(raw) as PainAiPlan;
  } catch (err) {
    console.error('[painAi] parse failed', raw?.slice(0, 400));
    return fallback();
  }
}

const SYSTEM_PROMPT = `You are a conservative physical therapy / sports medicine educator.
- You DO NOT provide medical diagnoses. Speak about "possible patterns" and "tissues" only.
- Safety first. If serious red flags are present, recommend seeing a doctor.
- Output STRICT JSON matching the required schema. Keep items concise (1-2 sentences).
- Focus on movement-based strategies, load management, and education.
- Always include a clear disclaimer that this is educational, not medical advice.`;

export async function generatePainPlan(
  userId: string,
  assessment: PainAssessmentRecord,
  photoFindings: PainPhotoFindings | null
): Promise<PainAiPlan> {
  const textBuckets = [
    assessment.notes ?? '',
    ...(assessment.functionalLimitations ?? []),
    ...(assessment.aggravatingFactors ?? []),
    ...(assessment.redFlags ?? []),
  ];
  const critical = hasCriticalFlags(assessment.redFlags ?? [], textBuckets);
  const defaultTriage: PainTriageLevel = fallbackTriage(assessment, critical);
  const basePlan = fallbackPlan(assessment, photoFindings, defaultTriage);

  const payload = {
    assessment,
    photoFindings,
    context: {
      bodyRegion: assessment.bodyRegion,
      side: assessment.side,
      painDuration: assessment.painDuration,
      painIntensity: assessment.painIntensity,
      painCharacter: assessment.painCharacter,
      aggravatingFactors: assessment.aggravatingFactors,
      relievingFactors: assessment.relievingFactors,
      activityContext: assessment.activityContext,
      redFlags: assessment.redFlags,
      hasRedFlags: assessment.hasRedFlags,
      functionalLimitations: assessment.functionalLimitations,
      notes: assessment.notes,
      photoSummary: photoFindings?.summaryText,
    },
  };

  const persistPlan = async (plan: PainAiPlan) => {
    const { error } = await supabase
      .from('pain_assessments')
      .update({
        triage_level: plan.triageLevel,
        ai_summary_json: plan,
        ai_version: 'v1',
      })
      .eq('user_id', userId)
      .eq('id', assessment.id);
    if (error) {
      console.error('[painAi] failed to persist plan', error.message, error.details);
    }
  };

  try {
    const raw = await callDeepSeek(SYSTEM_PROMPT, payload);
    const apiPlan = safeParsePlan(raw, () => basePlan);
    const triageLevel: PainTriageLevel = apiPlan.triageLevel ?? defaultTriage;
    const mergedPlan: PainAiPlan = {
      ...basePlan,
      ...apiPlan,
      triageLevel,
      showDoctorBanner: apiPlan.showDoctorBanner ?? triageLevel !== 'self_manage',
      doctorBannerTitle:
        apiPlan.doctorBannerTitle ??
        basePlan.doctorBannerTitle ??
        (triageLevel === 'see_doctor_soon' ? 'Please see a clinician' : triageLevel === 'caution' ? 'Monitor symptoms' : undefined),
      doctorBannerBody:
        apiPlan.doctorBannerBody ??
        basePlan.doctorBannerBody ??
        (triageLevel === 'see_doctor_soon'
          ? 'Your answers suggest potential red flags. Seek medical evaluation.'
          : triageLevel === 'caution'
          ? 'If symptoms worsen or persist, consult a healthcare professional.'
          : undefined),
      riskReasons: apiPlan.riskReasons?.length ? apiPlan.riskReasons : basePlan.riskReasons,
      summaryTitle: apiPlan.summaryTitle || basePlan.summaryTitle,
      summaryBody: apiPlan.summaryBody || basePlan.summaryBody,
      likelyTissues: apiPlan.likelyTissues?.length ? apiPlan.likelyTissues : basePlan.likelyTissues,
      aggravatingThemes: apiPlan.aggravatingThemes?.length ? apiPlan.aggravatingThemes : basePlan.aggravatingThemes,
      warmupAndMobility: apiPlan.warmupAndMobility?.length ? apiPlan.warmupAndMobility : basePlan.warmupAndMobility,
      strengthAndActivation: apiPlan.strengthAndActivation?.length ? apiPlan.strengthAndActivation : basePlan.strengthAndActivation,
      recoveryAdvice: apiPlan.recoveryAdvice?.length ? apiPlan.recoveryAdvice : basePlan.recoveryAdvice,
      safetyNotes:
        apiPlan.safetyNotes?.length && apiPlan.safetyNotes.filter((s) => s.trim().length > 0).length
          ? apiPlan.safetyNotes
          : basePlan.safetyNotes,
      disclaimer: apiPlan.disclaimer || basePlan.disclaimer,
      createdAt: apiPlan.createdAt || basePlan.createdAt,
    };

    await persistPlan(mergedPlan);
    return mergedPlan;
  } catch (err) {
    console.error('generatePainPlan DeepSeek failed', err);
    await persistPlan(basePlan);
    return basePlan;
  }
}

