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
  duration_minutes?: number | null;
  completed_at?: string | null;
  created_at: string;
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
