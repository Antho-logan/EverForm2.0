import { RecoveryAiContext, RecoveryDayMetrics, RecoveryProfile } from '../types';
import { getOrCreateRecoveryProfile } from './recoveryProfileService';

/**
 * Placeholder summary service until HealthKit / real metrics are wired.
 * Returns empty metrics so AI can still run with profile data.
 */
export async function getRecoveryMetricsForUser(
  userId: string,
  _opts: { lookbackDays?: number } = {}
): Promise<{ today: RecoveryDayMetrics | null; recentHistory: RecoveryDayMetrics[] }> {
  // TODO: integrate Apple Health / wearable data
  return {
    today: null,
    recentHistory: [],
  };
}

export async function buildRecoveryAiContext(userId: string): Promise<RecoveryAiContext> {
  const profile: RecoveryProfile = await getOrCreateRecoveryProfile(userId);
  const { today, recentHistory } = await getRecoveryMetricsForUser(userId, { lookbackDays: 14 });
  return { profile, today, recentHistory };
}

