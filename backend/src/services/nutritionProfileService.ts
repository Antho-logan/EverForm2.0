import { userSelect, userUpsert } from '../utils/db';
import { NutritionProfile, NutritionGoal, DietType, NutritionConstraints, BiohackerNutritionFlags } from '../types';

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const DEFAULT_NUTRITION_PROFILE: Omit<NutritionProfile, 'userId' | 'createdAt' | 'updatedAt'> = {
  goal: 'maintenance',
  calorieTarget: 2600,
  proteinTargetG: 180,
  carbTargetG: 280,
  fatTargetG: 80,
  dietType: 'omnivore',
  constraints: {},
  biohackerFlags: {},
};

function assertValidUserId(userId?: string) {
  if (!userId || !UUID_REGEX.test(userId)) {
    console.error('[NutritionProfileService] Invalid user id', { userId });
    throw new Error('Valid user id is required to fetch nutrition profile');
  }
}

function mapRowToProfile(row: any): NutritionProfile {
  return {
    userId: row.user_id,
    goal: row.goal as NutritionGoal,
    calorieTarget: row.calorie_target,
    proteinTargetG: row.protein_target_g,
    carbTargetG: row.carb_target_g,
    fatTargetG: row.fat_target_g,
    dietType: row.diet_type as DietType,
    constraints: (row.constraints ?? {}) as NutritionConstraints,
    biohackerFlags: (row.biohacker_flags ?? {}) as BiohackerNutritionFlags,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function mapUpdatesToDb(updates: Partial<NutritionProfile>) {
  const payload: Record<string, unknown> = {};
  if (updates.goal !== undefined) payload.goal = updates.goal;
  if (updates.calorieTarget !== undefined) payload.calorie_target = updates.calorieTarget;
  if (updates.proteinTargetG !== undefined) payload.protein_target_g = updates.proteinTargetG;
  if (updates.carbTargetG !== undefined) payload.carb_target_g = updates.carbTargetG;
  if (updates.fatTargetG !== undefined) payload.fat_target_g = updates.fatTargetG;
  if (updates.dietType !== undefined) payload.diet_type = updates.dietType;
  if (updates.constraints !== undefined) payload.constraints = updates.constraints;
  if (updates.biohackerFlags !== undefined) payload.biohacker_flags = updates.biohackerFlags;
  payload.updated_at = new Date().toISOString();
  return payload;
}

/**
 * Fetches the user's nutrition profile, creating a default one if it doesn't exist.
 */
export async function getOrCreateDefaultNutritionProfile(userId: string): Promise<NutritionProfile> {
  assertValidUserId(userId);

  // Try existing profile
  const { data: existing, error: selectError } = await userSelect('nutrition_profiles', userId).maybeSingle();
  if (selectError) {
    console.error('[NutritionProfileService] select failed', { userId, message: selectError.message });
    throw new Error(`Failed to fetch nutrition profile: ${selectError.message}`);
  }
  if (existing) {
    return mapRowToProfile(existing);
  }

  // Create default
  console.log(`[NutritionProfileService] Creating default nutrition profile for user ${userId}`);
  const dbPayload = mapUpdatesToDb(DEFAULT_NUTRITION_PROFILE);
  const { data, error: upsertError } = await userUpsert('nutrition_profiles', userId, dbPayload, 'user_id')
    .select()
    .single();

  if (upsertError) {
    console.error('[NutritionProfileService] upsert failed', { userId, message: upsertError.message });
    throw new Error(`Failed to create nutrition profile: ${upsertError.message}`);
  }

  if (!data) {
    throw new Error('Nutrition profile was not returned after creation');
  }

  return mapRowToProfile(data);
}

/**
 * Updates a user's nutrition profile with partial data.
 */
export async function updateNutritionProfile(
  userId: string,
  updates: Partial<NutritionProfile>
): Promise<NutritionProfile> {
  assertValidUserId(userId);
  const payload = mapUpdatesToDb(updates);

  const { data, error } = await userUpsert('nutrition_profiles', userId, payload, 'user_id')
    .select()
    .single();

  if (error) {
    console.error('[NutritionProfileService] update failed', { userId, message: error.message });
    throw new Error(`Failed to update nutrition profile: ${error.message}`);
  }

  if (!data) {
    throw new Error('Nutrition profile was not returned after update');
  }

  return mapRowToProfile(data);
}

