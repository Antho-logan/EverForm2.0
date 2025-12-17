import { EquipmentAccess, ExperienceLevel, SmartSessionType, SmartTrainingDay, SmartTrainingPlan, TrainingGoal, TrainingProfile } from '../types';
import { getOrCreateDefaultTrainingProfile } from './trainingProfileService';

const MIN_DAYS = 2;
const MAX_DAYS = 7;

/**
 * Generate a deterministic weekly smart training plan for a given user.
 * Uses the saved training profile as input and returns a 7-day plan with
 * session labels and metadata. This service does not persist any data.
 */
export async function generateSmartTrainingPlanForUser(userId: string): Promise<SmartTrainingPlan> {
  const profile = await getOrCreateDefaultTrainingProfile(userId);
  return buildPlanFromProfile(profile);
}

/**
 * Build a 7-day smart training plan using rule-based patterns derived from the
 * user's training profile. Clamps daysPerWeek to a sensible 2–7 range, then
 * aligns the weekly pattern to honor the requested frequency.
 */
export function buildPlanFromProfile(profile: TrainingProfile): SmartTrainingPlan {
  const daysPerWeek = clampDaysPerWeek(profile.days_per_week);
  const basePattern = buildPattern(profile.goal, daysPerWeek);
  const alignedPattern = alignPatternToFrequency(basePattern, profile.goal, daysPerWeek);

  const days: SmartTrainingDay[] = alignedPattern.map((type, index) =>
    buildDay(type, index, profile.experience_level, profile.equipment_access)
  );

  return {
    goal: profile.goal,
    daysPerWeek,
    experienceLevel: profile.experience_level,
    equipmentAccess: profile.equipment_access,
    days,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Pattern builders
// ─────────────────────────────────────────────────────────────────────────────

function clampDaysPerWeek(value: number): number {
  const clamped = Math.min(MAX_DAYS, Math.max(MIN_DAYS, value || MIN_DAYS));
  return Math.round(clamped);
}

function buildPattern(goal: TrainingGoal, daysPerWeek: number): SmartSessionType[] {
  if (goal === 'muscle_gain') {
    if (daysPerWeek <= 3) {
      return [
        'FULL_BODY_STRENGTH',
        'ACTIVE_RECOVERY',
        'FULL_BODY_STRENGTH',
        'MOBILITY_ONLY',
        'FULL_BODY_STRENGTH',
        'ACTIVE_RECOVERY',
        'ACTIVE_RECOVERY',
      ];
    }
    if (daysPerWeek <= 5) {
      return [
        'PUSH',
        'PULL',
        'LOWER_STRENGTH',
        'UPPER_STRENGTH',
        'CARDIO_ZONE2',
        'ACTIVE_RECOVERY',
        'MOBILITY_ONLY',
      ];
    }
    return [
      'UPPER_STRENGTH',
      'LOWER_STRENGTH',
      'PUSH',
      'PULL',
      'LOWER_STRENGTH',
      'UPPER_STRENGTH',
      'ACTIVE_RECOVERY',
    ];
  }

  if (goal === 'fat_loss') {
    if (daysPerWeek <= 3) {
      return [
        'FULL_BODY_STRENGTH',
        'CARDIO_ZONE2',
        'ACTIVE_RECOVERY',
        'FULL_BODY_STRENGTH',
        'CARDIO_ZONE2',
        'MOBILITY_ONLY',
        'ACTIVE_RECOVERY',
      ];
    }
    if (daysPerWeek <= 5) {
      return [
        'FULL_BODY_STRENGTH',
        'CARDIO_ZONE2',
        'LOWER_STRENGTH',
        'CARDIO_HIIT',
        'FULL_BODY_STRENGTH',
        'ACTIVE_RECOVERY',
        'MOBILITY_ONLY',
      ];
    }
    return [
      'FULL_BODY_STRENGTH',
      'CARDIO_ZONE2',
      'LOWER_STRENGTH',
      'CARDIO_HIIT',
      'UPPER_STRENGTH',
      'CARDIO_ZONE2',
      'ACTIVE_RECOVERY',
    ];
  }

  if (goal === 'performance') {
    if (daysPerWeek <= 3) {
      return [
        'FULL_BODY_STRENGTH',
        'CARDIO_ZONE2',
        'ACTIVE_RECOVERY',
        'LOWER_STRENGTH',
        'MOBILITY_ONLY',
        'CARDIO_HIIT',
        'ACTIVE_RECOVERY',
      ];
    }
    if (daysPerWeek <= 5) {
      return [
        'UPPER_STRENGTH',
        'LOWER_STRENGTH',
        'CARDIO_ZONE2',
        'PUSH',
        'ACTIVE_RECOVERY',
        'CARDIO_HIIT',
        'MOBILITY_ONLY',
      ];
    }
    return [
      'UPPER_STRENGTH',
      'LOWER_STRENGTH',
      'CARDIO_ZONE2',
      'PUSH',
      'PULL',
      'CARDIO_HIIT',
      'MOBILITY_ONLY',
    ];
  }

  // health | general_fitness
  if (daysPerWeek <= 3) {
    return [
      'FULL_BODY_STRENGTH',
      'ACTIVE_RECOVERY',
      'FULL_BODY_STRENGTH',
      'CARDIO_ZONE2',
      'ACTIVE_RECOVERY',
      'FULL_BODY_STRENGTH',
      'MOBILITY_ONLY',
    ];
  }
  if (daysPerWeek <= 5) {
    return [
      'FULL_BODY_STRENGTH',
      'CARDIO_ZONE2',
      'ACTIVE_RECOVERY',
      'FULL_BODY_STRENGTH',
      'CARDIO_ZONE2',
      'ACTIVE_RECOVERY',
      'MOBILITY_ONLY',
    ];
  }
  return [
    'FULL_BODY_STRENGTH',
    'CARDIO_ZONE2',
    'LOWER_STRENGTH',
    'ACTIVE_RECOVERY',
    'FULL_BODY_STRENGTH',
    'CARDIO_ZONE2',
    'MOBILITY_ONLY',
  ];
}

function alignPatternToFrequency(
  pattern: SmartSessionType[],
  goal: TrainingGoal,
  desiredTrainingDays: number
): SmartSessionType[] {
  const result = [...pattern];
  const isTraining = (type: SmartSessionType) => !isRestType(type);

  let trainingCount = result.filter(isTraining).length;

  if (trainingCount > desiredTrainingDays) {
    for (let i = result.length - 1; i >= 0 && trainingCount > desiredTrainingDays; i--) {
      if (isTraining(result[i])) {
        result[i] = 'ACTIVE_RECOVERY';
        trainingCount--;
      }
    }
  } else if (trainingCount < desiredTrainingDays) {
    const fallback = fallbackSessionType(goal);
    for (let i = 0; i < result.length && trainingCount < desiredTrainingDays; i++) {
      if (isRestType(result[i])) {
        result[i] = fallback;
        trainingCount++;
      }
    }
  }

  return result;
}

function fallbackSessionType(goal: TrainingGoal): SmartSessionType {
  switch (goal) {
    case 'muscle_gain':
      return 'FULL_BODY_STRENGTH';
    case 'fat_loss':
      return 'CARDIO_ZONE2';
    case 'performance':
      return 'CARDIO_ZONE2';
    case 'health':
    case 'general_fitness':
    default:
      return 'FULL_BODY_STRENGTH';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day builder helpers
// ─────────────────────────────────────────────────────────────────────────────

function buildDay(
  type: SmartSessionType,
  dayIndex: number,
  experience: ExperienceLevel,
  equipment: EquipmentAccess
): SmartTrainingDay {
  const isRestDay = isRestType(type);
  const label = buildLabel(type, equipment);
  const focusAreas = buildFocusAreas(type);
  const intensityHint = buildIntensity(type, experience);
  const estimatedMinutes = buildDuration(type, experience);

  return {
    dayIndex,
    label,
    type,
    focusAreas,
    intensityHint,
    estimatedMinutes,
    isRestDay,
  };
}

function isRestType(type: SmartSessionType): boolean {
  return type === 'ACTIVE_RECOVERY' || type === 'MOBILITY_ONLY';
}

function buildLabel(type: SmartSessionType, equipment: EquipmentAccess): string {
  const strengthSuffix =
    equipment === 'bodyweight_only'
      ? 'Calisthenics & Core'
      : equipment === 'limited_home'
      ? 'Dumbbell/Bands'
      : 'Strength';

  switch (type) {
    case 'FULL_BODY_STRENGTH':
      return equipment === 'bodyweight_only'
        ? 'Full Body Calisthenics'
        : `Full Body ${strengthSuffix}`;
    case 'UPPER_STRENGTH':
      return equipment === 'bodyweight_only' ? 'Upper Body Calisthenics' : 'Upper Body Strength';
    case 'LOWER_STRENGTH':
      return equipment === 'bodyweight_only' ? 'Lower Body Calisthenics' : 'Lower Body Strength & Glutes';
    case 'PUSH':
      return equipment === 'bodyweight_only' ? 'Push Calisthenics' : 'Push Strength (Chest/Shoulders/Triceps)';
    case 'PULL':
      return equipment === 'bodyweight_only' ? 'Pull Calisthenics' : 'Pull Strength (Back/Biceps)';
    case 'CARDIO_ZONE2':
      return 'Zone 2 Cardio / Steady State';
    case 'CARDIO_HIIT':
      return 'Conditioning / HIIT Intervals';
    case 'ACTIVE_RECOVERY':
      return 'Active Recovery & Steps';
    case 'MOBILITY_ONLY':
      return 'Mobility / Stretching';
    default:
      return 'Training';
  }
}

function buildFocusAreas(type: SmartSessionType): string[] {
  switch (type) {
    case 'FULL_BODY_STRENGTH':
      return ['full_body'];
    case 'UPPER_STRENGTH':
      return ['chest', 'back', 'shoulders', 'arms'];
    case 'LOWER_STRENGTH':
      return ['quads', 'glutes', 'hamstrings', 'calves'];
    case 'PUSH':
      return ['chest', 'shoulders', 'triceps'];
    case 'PULL':
      return ['back', 'biceps', 'posterior_chain'];
    case 'CARDIO_ZONE2':
      return ['aerobic_base', 'endurance'];
    case 'CARDIO_HIIT':
      return ['conditioning', 'power'];
    case 'ACTIVE_RECOVERY':
      return ['mobility', 'steps', 'restoration'];
    case 'MOBILITY_ONLY':
      return ['mobility', 'posture'];
    default:
      return [];
  }
}

function buildIntensity(type: SmartSessionType, experience: ExperienceLevel): 'low' | 'moderate' | 'high' {
  const base: Record<SmartSessionType, 'low' | 'moderate' | 'high'> = {
    FULL_BODY_STRENGTH: 'moderate',
    UPPER_STRENGTH: 'high',
    LOWER_STRENGTH: 'high',
    PUSH: 'high',
    PULL: 'high',
    CARDIO_ZONE2: 'moderate',
    CARDIO_HIIT: 'high',
    ACTIVE_RECOVERY: 'low',
    MOBILITY_ONLY: 'low',
  };

  const baseIntensity = base[type];
  if (experience === 'beginner' && baseIntensity === 'high') return 'moderate';
  if (experience === 'advanced' && baseIntensity === 'moderate' && type !== 'CARDIO_ZONE2') return 'high';
  return baseIntensity;
}

function buildDuration(type: SmartSessionType, experience: ExperienceLevel): number {
  const baseMinutes: Record<SmartSessionType, number> = {
    FULL_BODY_STRENGTH: 55,
    UPPER_STRENGTH: 60,
    LOWER_STRENGTH: 60,
    PUSH: 55,
    PULL: 55,
    CARDIO_ZONE2: 40,
    CARDIO_HIIT: 30,
    ACTIVE_RECOVERY: 30,
    MOBILITY_ONLY: 20,
  };

  const base = baseMinutes[type];
  if (experience === 'beginner') {
    return Math.max(20, base - 10);
  }
  if (experience === 'advanced') {
    return Math.min(90, base + 10);
  }
  return base;
}





