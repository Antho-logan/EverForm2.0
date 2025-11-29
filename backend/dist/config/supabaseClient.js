"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.supabase = void 0;
// Creates a Supabase client in service role mode. Service role bypasses RLS, so handlers must always filter by user_id.
const supabase_js_1 = require("@supabase/supabase-js");
const env_1 = require("./env");
exports.supabase = (0, supabase_js_1.createClient)(env_1.env.SUPABASE_URL, env_1.env.SUPABASE_SERVICE_ROLE_KEY);
//# sourceMappingURL=supabaseClient.js.map