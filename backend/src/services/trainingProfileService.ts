/**
 * Training Profile Service
 * 
 * Provides access to per-user training profiles for the Smart Training engine.
 * Each user has at most one training_profiles row; if none exists, this service
 * creates a default row on first access.
 * 
 * TODO: Potential overlap with other profile sources:
 *   - `profiles.training_experience` (beginner/intermediate/advanced/elite)
 *   - `goals.primary_goal`, `goals.equipment_access`, `goals.preferred_training_days`
 * Consider adding a sync/reconciliation step in the future, or migrating all
 * training-related preferences into this single table.
 */

import { userSelect, userUpsert } from '../utils/db';
import { TrainingProfile, TrainingGoal, ExperienceLevel, EquipmentAccess } from '../types';

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function assertValidUserId(userId?: string) {
  if (!userId || !UUID_REGEX.test(userId)) {
    console.error('[TrainingProfileService] Invalid user id', { userId });
    throw new Error('Valid user id is required to fetch training profile');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Default Values
// ─────────────────────────────────────────────────────────────────────────────

const DEFAULT_TRAINING_PROFILE: Omit<TrainingProfile, 'user_id' | 'created_at' | 'updated_at'> = {
  goal: 'general_fitness',
  days_per_week: 3,
  experience_level: 'beginner',
  equipment_access: 'full_gym',
};

// ─────────────────────────────────────────────────────────────────────────────
// Service Functions
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Fetches the user's training profile, creating a default one if it doesn't exist.
 * 
 * @param userId - The authenticated user's ID
 * @returns The user's TrainingProfile (existing or newly created)
 * @throws Error if database operation fails
 */
export async function getOrCreateDefaultTrainingProfile(userId: string): Promise<TrainingProfile> {
  assertValidUserId(userId);

  try {
  // 1. Try to fetch existing profile
  const { data: existing, error: selectError } = await userSelect('training_profiles', userId)
    .maybeSingle();

  if (selectError) {
      console.error('[TrainingProfileService] select failed', {
        userId,
        message: selectError.message,
        details: selectError.details,
      });
    throw new Error(`Failed to fetch training profile: ${selectError.message}`);
  }

  // 2. If profile exists, return it (cast via unknown for Supabase generic typing)
  if (existing && typeof existing === 'object' && 'user_id' in existing) {
    return existing as unknown as TrainingProfile;
  }

  // 3. No profile exists - create default
    console.log(`[TrainingProfileService] Creating default training profile for user ${userId}`);

  const defaults = {
    ...DEFAULT_TRAINING_PROFILE,
    updated_at: new Date().toISOString(),
  };

  const { data: created, error: upsertError } = await userUpsert('training_profiles', userId, defaults, 'user_id')
    .select()
    .single();

  if (upsertError) {
      console.error('[TrainingProfileService] upsert failed', {
        userId,
        message: upsertError.message,
        details: upsertError.details,
      });
    throw new Error(`Failed to create training profile: ${upsertError.message}`);
  }

  if (!created || typeof created !== 'object') {
    throw new Error('Training profile was not returned after creation');
  }

  return created as unknown as TrainingProfile;
  } catch (err) {
    console.error('[TrainingProfileService] unexpected error', err);
    throw err;
  }
}

/**
 * Updates a user's training profile with partial data.
 * Creates the profile if it doesn't exist (upsert behavior).
 * 
 * @param userId - The authenticated user's ID
 * @param updates - Partial training profile fields to update
 * @returns The updated TrainingProfile
 * @throws Error if database operation fails
 */
export async function updateTrainingProfile(
  userId: string,
  updates: Partial<Pick<TrainingProfile, 'goal' | 'days_per_week' | 'experience_level' | 'equipment_access'>>
): Promise<TrainingProfile> {
  assertValidUserId(userId);

  const payload = {
    ...updates,
    updated_at: new Date().toISOString(),
  };

  const { data, error } = await userUpsert('training_profiles', userId, payload, 'user_id')
    .select()
    .single();

  if (error) {
    console.error('[TrainingProfileService] update failed', {
      userId,
      message: error.message,
      details: error.details,
    });
    throw new Error(`Failed to update training profile: ${error.message}`);
  }

  if (!data || typeof data !== 'object') {
    throw new Error('Training profile was not returned after update');
  }

  return data as unknown as TrainingProfile;
}

// ─────────────────────────────────────────────────────────────────────────────
// Re-export types for convenience
// ─────────────────────────────────────────────────────────────────────────────

export type { TrainingProfile, TrainingGoal, ExperienceLevel, EquipmentAccess };

export function mapTrainingProfileToResponse(profile: TrainingProfile) {
  return {
    goal: profile.goal,
    daysPerWeek: profile.days_per_week,
    experienceLevel: profile.experience_level,
    equipmentAccess: profile.equipment_access,
    createdAt: profile.created_at,
    updatedAt: profile.updated_at,
  };
}

