/**
 * Database Helpers
 * 
 * Provides user-scoped query builders to prevent accidental data leaks.
 * All user-facing routes should use these helpers instead of raw supabase client.
 * 
 * Usage:
 *   import { userQuery, userInsert, userUpdate } from '../utils/db';
 *   
 *   // SELECT with automatic user_id filtering
 *   const { data } = await userQuery('nutrition_logs', userId).select('*');
 *   
 *   // INSERT with automatic user_id injection
 *   const { data } = await userInsert('nutrition_logs', userId, { date, food_name, ... });
 *   
 *   // UPDATE with automatic user_id scoping
 *   const { data } = await userUpdate('goals', userId, { primary_goal: 'muscle_gain' });
 */

import { supabase } from '../config/supabaseClient';

type TableName = string;
type UserId = string;

/**
 * Returns a query builder scoped to a specific user.
 * The returned builder has `.eq('user_id', userId)` automatically applied.
 * 
 * @example
 * const { data } = await userQuery('training_logs', userId)
 *   .select('*')
 *   .eq('date_performed', date);
 */
export function userQuery(table: TableName, userId: UserId) {
  return supabase.from(table).select().eq('user_id', userId);
}

/**
 * Returns a select query builder scoped to a specific user with custom select clause.
 * 
 * @example
 * const { data } = await userSelect('training_sessions', userId, '*, training_exercises(*)')
 *   .eq('date_planned', date);
 */
export function userSelect(table: TableName, userId: UserId, columns: string = '*') {
  return supabase.from(table).select(columns).eq('user_id', userId);
}

/**
 * Inserts a row with user_id automatically injected into the payload.
 * Returns a query builder so you can chain `.select()`.
 * 
 * @example
 * const { data, error } = await userInsert('nutrition_logs', userId, {
 *   date: '2025-01-15',
 *   food_name: 'Chicken breast',
 *   protein_g: 31
 * }).select().single();
 */
export function userInsert<T extends Record<string, unknown>>(
  table: TableName,
  userId: UserId,
  payload: T
) {
  const payloadWithUser = { ...payload, user_id: userId };
  return supabase.from(table).insert(payloadWithUser);
}

/**
 * Updates rows scoped to a specific user.
 * Automatically adds `.eq('user_id', userId)` to prevent cross-user updates.
 * 
 * @example
 * const { data, error } = await userUpdate('goals', userId, {
 *   primary_goal: 'fat_loss',
 *   updated_at: new Date().toISOString()
 * }).select().single();
 */
export function userUpdate<T extends Record<string, unknown>>(
  table: TableName,
  userId: UserId,
  payload: T
) {
  return supabase.from(table).update(payload).eq('user_id', userId);
}

/**
 * Upserts a row with user_id automatically injected.
 * Use for tables where user_id is part of the unique constraint.
 * 
 * @example
 * const { data, error } = await userUpsert('nutrition_targets', userId, {
 *   daily_calories: 2500,
 *   protein_g: 180
 * }, 'user_id').select().single();
 */
export function userUpsert<T extends Record<string, unknown>>(
  table: TableName,
  userId: UserId,
  payload: T,
  onConflict: string = 'user_id'
) {
  const payloadWithUser = { ...payload, user_id: userId };
  return supabase.from(table).upsert(payloadWithUser, { onConflict });
}

/**
 * Deletes rows scoped to a specific user.
 * 
 * @example
 * const { error } = await userDelete('coach_messages', userId)
 *   .eq('id', messageId);
 */
export function userDelete(table: TableName, userId: UserId) {
  return supabase.from(table).delete().eq('user_id', userId);
}

/**
 * Fetches a single row by ID, ensuring it belongs to the user.
 * Returns null if not found or doesn't belong to user.
 * 
 * @example
 * const { data } = await userGetById('training_logs', userId, logId);
 */
export async function userGetById(
  table: TableName,
  userId: UserId,
  id: string,
  columns: string = '*'
) {
  const { data, error } = await supabase
    .from(table)
    .select(columns)
    .eq('user_id', userId)
    .eq('id', id)
    .maybeSingle();

  if (error) {
    console.error(`[db] userGetById error on ${table}:`, error.message);
    return { data: null, error };
  }

  return { data, error: null };
}

/**
 * Raw supabase client for admin/job operations that don't need user scoping.
 * Use sparingly - prefer the scoped helpers for user-facing routes.
 */
export { supabase as adminClient };








