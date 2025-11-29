// Creates a Supabase client in service role mode. Service role bypasses RLS, so handlers must always filter by user_id.
import { createClient } from '@supabase/supabase-js';
import { env } from './env';

export const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY);
