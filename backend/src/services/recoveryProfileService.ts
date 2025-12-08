import { userSelect, userUpsert } from '../utils/db';
import { RecoveryGoal, RecoveryProfile } from '../types';

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const DEFAULT_RECOVERY_PROFILE: Omit<
  RecoveryProfile,
  'userId' | 'createdAt' | 'updatedAt'
> = {
  goal: 'optimal',
  targetSleepMinutes: 480,
  preferredBedtime: null,
  preferredWakeTime: null,
  caffeineCutoffHour: 16,
  timezone: 'Europe/Amsterdam',
};

function assertValidUserId(userId?: string) {
  if (!userId || !UUID_REGEX.test(userId)) {
    console.error('[RecoveryProfileService] Invalid user id', { userId });
    throw new Error('Valid user id is required to fetch recovery profile');
  }
}

function assertBounds(patch: Partial<RecoveryProfile>) {
  if (patch.targetSleepMinutes !== undefined) {
    if (patch.targetSleepMinutes < 240 || patch.targetSleepMinutes > 600) {
      throw new Error('targetSleepMinutes must be between 240 and 600');
    }
  }
  if (patch.caffeineCutoffHour !== undefined && patch.caffeineCutoffHour !== null) {
    if (patch.caffeineCutoffHour < 0 || patch.caffeineCutoffHour > 23) {
      throw new Error('caffeineCutoffHour must be between 0 and 23');
    }
  }
}

function mapRowToProfile(row: any): RecoveryProfile {
  return {
    userId: row.user_id,
    goal: row.goal as RecoveryGoal,
    targetSleepMinutes: row.target_sleep_minutes,
    preferredBedtime: row.preferred_bedtime,
    preferredWakeTime: row.preferred_wake_time,
    caffeineCutoffHour: row.caffeine_cutoff_hour,
    timezone: row.timezone,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function mapUpdatesToDb(updates: Partial<RecoveryProfile>) {
  const payload: Record<string, unknown> = {};
  if (updates.goal !== undefined) payload.goal = updates.goal;
  if (updates.targetSleepMinutes !== undefined) payload.target_sleep_minutes = updates.targetSleepMinutes;
  if (updates.preferredBedtime !== undefined) payload.preferred_bedtime = updates.preferredBedtime;
  if (updates.preferredWakeTime !== undefined) payload.preferred_wake_time = updates.preferredWakeTime;
  if (updates.caffeineCutoffHour !== undefined) payload.caffeine_cutoff_hour = updates.caffeineCutoffHour;
  if (updates.timezone !== undefined) payload.timezone = updates.timezone;
  payload.updated_at = new Date().toISOString();
  return payload;
}

export async function getOrCreateRecoveryProfile(userId: string): Promise<RecoveryProfile> {
  assertValidUserId(userId);

  const { data: existing, error: selectError } = await userSelect('recovery_profiles', userId).maybeSingle();
  if (selectError) {
    console.error('[RecoveryProfileService] select failed', {
      userId,
      message: selectError.message,
      details: selectError.details,
    });
    throw new Error(`Failed to fetch recovery profile: ${selectError.message}`);
  }
  if (existing) {
    return mapRowToProfile(existing);
  }

  console.log(`[RecoveryProfileService] Creating default recovery profile for user ${userId}`);
  const dbPayload = mapUpdatesToDb(DEFAULT_RECOVERY_PROFILE);
  const { data, error: upsertError } = await userUpsert('recovery_profiles', userId, dbPayload, 'user_id')
    .select()
    .single();

  if (upsertError) {
    console.error('[RecoveryProfileService] upsert failed', {
      userId,
      message: upsertError.message,
      details: upsertError.details,
    });
    throw new Error(`Failed to create recovery profile: ${upsertError.message}`);
  }

  if (!data) {
    throw new Error('Recovery profile was not returned after creation');
  }

  return mapRowToProfile(data);
}

export async function updateRecoveryProfile(
  userId: string,
  patch: Partial<{
    goal: RecoveryGoal;
    targetSleepMinutes: number;
    preferredBedtime: string | null;
    preferredWakeTime: string | null;
    caffeineCutoffHour: number | null;
    timezone: string;
  }>
): Promise<RecoveryProfile> {
  assertValidUserId(userId);
  assertBounds(patch);

  const payload = mapUpdatesToDb(patch as Partial<RecoveryProfile>);

  const { data, error } = await userUpsert('recovery_profiles', userId, payload, 'user_id')
    .select()
    .single();

  if (error) {
    console.error('[RecoveryProfileService] update failed', {
      userId,
      message: error.message,
      details: error.details,
    });
    throw new Error(`Failed to update recovery profile: ${error.message}`);
  }

  if (!data) {
    throw new Error('Recovery profile was not returned after update');
  }

  return mapRowToProfile(data);
}

