/**
 * Supabase Client Configuration
 * 
 * Provides two clients for different use cases:
 * 
 * 1. `supabase` (service role) - Bypasses RLS. Use ONLY for:
 *    - Scheduled jobs (daily/weekly reports)
 *    - Admin operations
 *    - Cross-user queries (e.g., listing all users for batch jobs)
 *    - System-generated data (coach messages, summaries)
 * 
 * 2. `supabaseUser` (anon key) - Respects RLS. Use for:
 *    - All user-facing API handlers
 *    - User data reads/writes
 *    - Any operation where user context matters
 * 
 * NOTE: If SUPABASE_ANON_KEY is not set, supabaseUser falls back to service role
 * (less secure but functional for dev). In production, always set SUPABASE_ANON_KEY.
 */

import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { env } from './env';

/**
 * Admin/Service Role Client
 * 
 * SECURITY: This client bypasses RLS entirely. Only use for:
 * - Scheduled jobs and background tasks
 * - Admin-level operations
 * - Cross-user batch operations
 * 
 * For user-facing routes, prefer supabaseUser + db.ts helpers.
 */
export const supabase: SupabaseClient = createClient(
  env.SUPABASE_URL,
  env.SUPABASE_SERVICE_ROLE_KEY
);

/**
 * User-Context Client (respects RLS)
 * 
 * Use this client with db.ts helpers for user-facing routes.
 * Falls back to service role if SUPABASE_ANON_KEY is not configured.
 */
export const supabaseUser: SupabaseClient = env.SUPABASE_ANON_KEY
  ? createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY)
  : supabase; // Fallback: service role (RLS won't be enforced)

/**
 * Alias for backwards compatibility - same as supabase (service role)
 * 
 * @deprecated Use `supabase` for admin ops or `supabaseUser` + db helpers for user ops
 */
export const adminClient = supabase;
