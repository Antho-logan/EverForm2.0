// Shared TypeScript interfaces mirroring the Supabase schema and service contracts.
import { Request } from 'express';

export interface AuthenticatedRequest extends Request {
  user?: { id: string };
}

export interface Profile {
  id: string;
  user_id: string;
  full_name?: string | null;
  email?: string | null;
  date_of_birth?: string | null;
  gender?: string | null;
  height_cm?: number | null;
  weight_kg?: number | null;
  activity_level?: string | null;
  primary_goal?: string | null;
  created_at: string;
}

export interface OnboardingAnswer {
  id: string;
  user_id: string;
  question_key: string;
  answer_text?: string | null;
  answer_numeric?: number | null;
  metadata?: Record<string, unknown> | null;
  created_at: string;
}

export interface WorkoutPlan {
  id: string;
  user_id: string;
  name: string;
  goal?: string | null;
  weeks?: number | null;
  plan_json?: Record<string, unknown> | null;
  created_at: string;
}

export interface WorkoutSession {
  id: string;
  user_id: string;
  plan_id?: string | null;
  title: string;
  status: 'completed' | 'skipped' | 'planned' | string;
  duration_minutes?: number | null;
  performed_at?: string | null;
  notes?: string | null;
  created_at: string;
}

export interface Meal {
  id: string;
  user_id: string;
  meal_type: string;
  title: string;
  kcal?: number | null;
  protein_g?: number | null;
  carbs_g?: number | null;
  fat_g?: number | null;
  logged_at: string;
  source?: string | null;
  created_at: string;
}

export interface RecoveryLog {
  id: string;
  user_id: string;
  sleep_hours?: number | null;
  sleep_score?: number | null;
  stress_level?: number | null;
  notes?: string | null;
  logged_at: string;
  created_at: string;
}

export interface MobilityRoutine {
  id: string;
  user_id: string;
  name: string;
  target_areas?: string[] | null;
  duration_minutes?: number | null;
  routine_json?: Record<string, unknown> | null;
  created_at: string;
}

export interface MobilitySession {
  id: string;
  user_id: string;
  routine_id?: string | null;
  status: string;
  performed_at?: string | null;
  created_at: string;
  mobility_routines?: MobilityRoutine;
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobility Assessments & AI
// ─────────────────────────────────────────────────────────────────────────────

export interface MobilityTestResult {
  testId: string;
  testName: string;
  joint: 'hips' | 'thoracic' | 'shoulders' | 'ankles' | 'full_body' | 'other';
  rangeOfMotionScore?: number; // 1–5
  controlScore?: number;       // 1–5
  pain?: boolean;
  notes?: string;
}

export interface MobilityJointScores {
  hipsScore?: number;
  thoracicScore?: number;
  shouldersScore?: number;
  anklesScore?: number;
}

export interface MobilityAssessmentInput {
  tests: MobilityTestResult[];
  notes?: string;
}

export interface MobilityAssessment extends MobilityJointScores {
  id: string;
  userId: string;
  createdAt: string;
  overallScore: number;
  rawResults: MobilityTestResult[];
  notes?: string;
}

export interface MobilityProfile extends MobilityJointScores {
  userId: string;
  overallScore: number;
  focusAreas: string[];
  riskNotes: string[];
  lastAssessmentAt: string;
  summaryJson?: Record<string, unknown>;
}

export interface MobilityAssessmentSummary {
  profile: MobilityProfile;
  aiSummaryText: string;
  focusTags: string[];
  recommendedRoutines: {
    id: string;
    name: string;
    priority: 'high' | 'medium' | 'low';
    frequencyPerWeek?: number;
  }[];
  weeklyPlanText: string;
}

export interface MobilityWeeklyFocus {
  averageScore?: number;
  fromDate: string;
  toDate: string;
  focusTitle: string;
  focusTags: string[];
  warnings: string[];
  coachInsight: string;
}

export interface PainCheck {
  id: string;
  user_id: string;
  area: string;
  severity: number;
  description?: string | null;
  recommendation_json?: Record<string, unknown> | null;
  created_at: string;
}

export interface BreathworkSession {
  id: string;
  user_id: string;
  technique: string;
  pattern_id?: string | null;
  pattern_name?: string | null;
  duration_minutes?: number | null;
  rounds_completed?: number | null;
  longest_hold_seconds?: number | null;
  notes?: string | null;
  completed_at?: string | null;
  created_at: string;
}

export interface BreathworkPatternDTO {
  id: string;
  type: string;
  displayName: string;
  description: string;
  targetEffect: string;
  defaultRounds: number;
  phases: {
    type: 'Inhale' | 'Hold' | 'Exhale' | 'Retention';
    durationSeconds: number;
    instruction?: string;
  }[];
}

export interface BreathworkSessionDTO {
  id: string;
  patternId: string;
  patternName: string;
  durationSeconds: number;
  roundsCompleted: number;
  longestHoldSeconds: number;
  notes?: string | null;
  createdAt: string;
}

// ─────────────────────────────────────────────────────────────────────────────
// Breathwork AI
// ─────────────────────────────────────────────────────────────────────────────

export interface BreathworkAiTodaySuggestion {
  suggestedPatternId: string | null;
  suggestedPatternName: string;
  suggestedRounds: number;
  suggestedMinutes: number;
  suggestionReason: string;
  focusTags: string[];
}

export interface BreathworkAiWeeklyInsight {
  periodStart: string;
  periodEnd: string;
  totalSessions: number;
  totalMinutes: number;
  streakDays: number;
  trendLabel: 'up' | 'down' | 'flat';
  insightText: string;
  focusTags: string[];
  recommendedFocus: string;
}

// ─────────────────────────────────────────────────────────────────────────────
// FixPain AI / Assessments
// ─────────────────────────────────────────────────────────────────────────────

export type PainBodyRegion =
  | 'neck'
  | 'upper_back'
  | 'lower_back'
  | 'shoulder'
  | 'hip'
  | 'knee'
  | 'ankle'
  | 'elbow'
  | 'wrist'
  | 'hand'
  | 'foot';

export type PainSide = 'left' | 'right' | 'both' | 'center' | 'unspecified';

export type PainDuration = 'acute' | 'subacute' | 'chronic' | 'sudden' | 'unknown';

export type PainTriageLevel = 'self_manage' | 'caution' | 'see_doctor_soon';

export interface PainAssessmentInput {
  bodyRegion: PainBodyRegion;
  side: PainSide;
  painDuration: PainDuration;
  painIntensity: number; // 0–10
  painCharacter: string[];
  aggravatingFactors: string[];
  relievingFactors: string[];
  activityContext: string[];
  redFlags: string[];
  functionalLimitations: string[];
  notes?: string;
  photoUrl?: string;
}

export interface PainAiSectionItem {
  title: string;
  description: string;
  iconKey?: string;
  durationMinutes?: number;
}

export interface PainAiPlan {
  triageLevel: PainTriageLevel;
  showDoctorBanner: boolean;
  doctorBannerTitle?: string;
  doctorBannerBody?: string;
  riskReasons: string[];

  summaryTitle: string;
  summaryBody: string;

  likelyTissues: string[];
  aggravatingThemes: string[];

  warmupAndMobility: PainAiSectionItem[];
  strengthAndActivation: PainAiSectionItem[];
  recoveryAdvice: PainAiSectionItem[];

  safetyNotes: string[];
  disclaimer: string;

  createdAt: string;
}

export interface PainAssessmentRecord extends PainAssessmentInput {
  id: string;
  userId: string;
  createdAt: string;
  triageLevel: PainTriageLevel;
  hasRedFlags: boolean;
  aiSummaryJson?: PainAiPlan;
  aiVersion: string;
}

export interface LookmaxSession {
  id: string;
  user_id: string;
  category: string;
  plan_json?: Record<string, unknown> | null;
  notes?: string | null;
  created_at: string;
}

export interface PersonalPlan {
  trainingPlan: Record<string, unknown>;
  nutritionPlan: Record<string, unknown>;
  recoveryPlan: Record<string, unknown>;
  mobilityPlan: Record<string, unknown>;
  painPreventionPlan: Record<string, unknown>;
  breathworkPlan: Record<string, unknown>;
  lookmaxPlan: Record<string, unknown>;
}

export interface ScannedFood {
  name: string;
  brand?: string;
  kcalPerServing?: number;
  proteinPerServing?: number;
  carbsPerServing?: number;
  fatPerServing?: number;
  servingSize?: string;
}

export interface PillarRecentData {
  trainingSessions: WorkoutSession[];
  meals: Meal[];
  recoveryLogs: RecoveryLog[];
  mobilitySessions: MobilitySession[];
  painChecks: PainCheck[];
  breathworkSessions: BreathworkSession[];
  lookmaxSessions: LookmaxSession[];
}

// ─────────────────────────────────────────────────────────────────────────────
// Training Profile for Smart Training Engine
// ─────────────────────────────────────────────────────────────────────────────
// NOTE: There is some overlap with existing Profile and Goals types:
//   - Profile.activity_level, Profile.primary_goal
//   - Goals have equipment_access, primary_goal, preferred_training_days
// This type is purpose-built for the Smart Training engine. A future
// refactor may consolidate these into a single source of truth.
// ─────────────────────────────────────────────────────────────────────────────

export type TrainingGoal = 'muscle_gain' | 'fat_loss' | 'performance' | 'health' | 'general_fitness';
export type ExperienceLevel = 'beginner' | 'intermediate' | 'advanced';
export type EquipmentAccess = 'full_gym' | 'limited_home' | 'bodyweight_only';

/**
 * TrainingProfile - Per-user training preferences (mirrors DB: training_profiles)
 * 
 * DB column names are snake_case; this interface uses the same naming for
 * direct mapping with Supabase query results.
 */
export interface TrainingProfile {
  user_id: string;                    // DB PK, references auth.users(id)
  goal: TrainingGoal;
  days_per_week: number;              // 0-14
  experience_level: ExperienceLevel;
  equipment_access: EquipmentAccess;
  created_at: string;                 // ISO timestamp
  updated_at: string;                 // ISO timestamp
}

// ─────────────────────────────────────────────────────────────────────────────
// Smart Training Engine Types
// ─────────────────────────────────────────────────────────────────────────────

export type SmartSessionType =
  | 'FULL_BODY_STRENGTH'
  | 'UPPER_STRENGTH'
  | 'LOWER_STRENGTH'
  | 'PUSH'
  | 'PULL'
  | 'CARDIO_ZONE2'
  | 'CARDIO_HIIT'
  | 'ACTIVE_RECOVERY'
  | 'MOBILITY_ONLY';

export interface SmartTrainingDay {
  dayIndex: number; // 0–6
  label: string;
  type: SmartSessionType;
  focusAreas: string[];
  intensityHint: 'low' | 'moderate' | 'high';
  estimatedMinutes: number;
  isRestDay: boolean;
}

export interface SmartTrainingPlan {
  goal: TrainingGoal;
  daysPerWeek: number;
  experienceLevel: ExperienceLevel;
  equipmentAccess: EquipmentAccess;
  days: SmartTrainingDay[];
}

// ─────────────────────────────────────────────────────────────────────────────
// Nutrition Types
// ─────────────────────────────────────────────────────────────────────────────

export type NutritionGoal =
  | 'maintenance'
  | 'fat_loss'
  | 'recomposition'
  | 'muscle_gain'
  | 'performance'
  | 'longevity';

export type DietType =
  | 'omnivore'
  | 'high_protein'
  | 'mediterranean'
  | 'vegetarian'
  | 'vegan'
  | 'low_carb'
  | 'low_fat';

export interface NutritionConstraints {
  glutenFree?: boolean;
  dairyFree?: boolean;
  nutAllergy?: boolean;
  halal?: boolean;
  kosher?: boolean;
  pescatarian?: boolean;
}

export interface BiohackerNutritionFlags {
  fastingWindowStart?: string; // "HH:MM"
  fastingWindowEnd?: string;   // "HH:MM"
  caffeineCutoffHour?: number; // 0-23
  lateMealCutoffHour?: number; // 0-23
}

export interface NutritionProfile {
  userId: string;
  goal: NutritionGoal;
  calorieTarget: number;   // kcal
  proteinTargetG: number;
  carbTargetG: number;
  fatTargetG: number;
  dietType: DietType;
  constraints: NutritionConstraints;
  biohackerFlags?: BiohackerNutritionFlags;
  createdAt: string;
  updatedAt: string;
}

export interface MacroSummary {
  target: number;
  consumed: number;
  remaining: number;
  unit: string; // "kcal" or "g"
}

export interface MicroSummary {
  key: string;   // "magnesium", "vitamin_d", etc.
  label: string; // human readable
  unit: string;  // "mg", "IU", etc.
  target?: number;
  consumed?: number;
}

export interface DailyNutritionSummary {
  date: string;
  energy: MacroSummary;
  protein: MacroSummary;
  carbs: MacroSummary;
  fat: MacroSummary;
  micros: MicroSummary[];
}

export interface NutritionAction {
  label: string;   // short, UI-friendly
  detail: string;  // 1–2 sentences
}

export interface DailyNutritionInsights {
  headline: string;
  summary: string;
  actions: NutritionAction[];
  micronutrientInsights?: NutritionAction[];
}

export interface SuggestedMeal {
  slot: 'breakfast' | 'lunch' | 'dinner' | 'snack' | 'any';
  name: string;
  macros: {
    kcal: number;
    proteinG: number;
    carbsG: number;
    fatG: number;
  };
  difficulty: 'easy' | 'moderate' | 'hard';
  prepTimeMinutes?: number;
  ingredients?: string[];
  notes?: string;
}

export interface SmartDayPlan {
  date: string;
  remaining: {
    kcal: number;
    proteinG: number;
    carbsG: number;
    fatG: number;
  };
  meals: SuggestedMeal[];
}

// ─────────────────────────────────────────────────────────────────────────────
// Recovery Types
// ─────────────────────────────────────────────────────────────────────────────

export type RecoveryGoal = 'optimal' | 'fix_insomnia' | 'post_cut' | 'stress_control';

export interface RecoveryProfile {
  userId: string;
  goal: RecoveryGoal;
  targetSleepMinutes: number;
  preferredBedtime: string | null;    // ISO time or HH:MM
  preferredWakeTime: string | null;   // ISO time or HH:MM
  caffeineCutoffHour: number | null;  // 0-23 or null
  timezone: string;
  createdAt: string;
  updatedAt: string;
}

export interface RecoveryInsight {
  headline: string;                    // e.g. "You're 2 days behind on deep sleep"
  summary: string;                     // 2–4 sentence explanation
  recoveryScore: number;               // 0–100
  sleepConsistency: number;            // 0–100
  nervousSystemLoad: 'low' | 'medium' | 'high';
  keyIssues: string[];
  todayFocusTags: string[];
}

export interface RecoveryPlanStep {
  title: string;                       // e.g. "T-60: Dim lights & no screens"
  description: string;                 // detailed instruction
  relativeMinutes?: number;            // e.g. -60 for 60 minutes before bedtime
}

export interface DailyRecoveryPlan {
  date: string;                        // 'YYYY-MM-DD'
  headline: string;
  planType: 'nightly' | 'reset' | 'maintenance';
  steps: RecoveryPlanStep[];
}

export interface RecoveryDayMetrics {
  date: string;                        // 'YYYY-MM-DD'
  sleepMinutes?: number;
  efficiencyPercent?: number;
  deepMinutes?: number;
  remMinutes?: number;
  lightMinutes?: number;
  awakeMinutes?: number;
  trainingLoad?: number;               // 0–10 subjective or from training system
  recoveryActions?: string[];          // e.g. ['sauna', 'mobility', 'breathwork']
}

export interface RecoveryAiContext {
  profile: RecoveryProfile;
  today: RecoveryDayMetrics | null;
  recentHistory: RecoveryDayMetrics[]; // last 7–14 days, can be empty
}
