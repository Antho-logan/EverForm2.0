"use strict";
/**
 * Environment Configuration
 *
 * Loads and validates environment variables.
 *
 * DEV MODE is enabled when:
 *   - NODE_ENV=development (from npm run dev), OR
 *   - ALLOW_DEV_USER=true (explicit opt-in)
 *
 * PROD MODE is enabled when:
 *   - Neither of the above conditions are true
 *
 * SECURITY:
 *   - In production (NODE_ENV=production), ALLOW_DEV_USER=true will still enable
 *     dev mode BUT will log a loud security warning. Remove ALLOW_DEV_USER in prod!
 */
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEV_USER_ID = exports.isDevMode = exports.env = void 0;
const dotenv_1 = __importDefault(require("dotenv"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const zod_1 = require("zod");
// Try multiple paths to find .env
const possiblePaths = [
    path_1.default.resolve(__dirname, '../../.env'), // Works for both src/ and dist/
    path_1.default.resolve(process.cwd(), '.env'), // Fallback: CWD (backend root)
    path_1.default.resolve(process.cwd(), 'backend/.env'), // Fallback: if running from project root
];
let loadedEnvPath = null;
for (const envPath of possiblePaths) {
    if (fs_1.default.existsSync(envPath)) {
        dotenv_1.default.config({ path: envPath });
        loadedEnvPath = envPath;
        break;
    }
}
// ─────────────────────────────────────────────────────────────────────────────
// ENV SCHEMA
// ─────────────────────────────────────────────────────────────────────────────
const envSchema = zod_1.z.object({
    PORT: zod_1.z.coerce.number().default(4000),
    NODE_ENV: zod_1.z.enum(['development', 'production', 'test']).default('development'),
    SUPABASE_URL: zod_1.z.string().url({ message: 'SUPABASE_URL must be a valid URL' }),
    SUPABASE_ANON_KEY: zod_1.z.string().optional(),
    SUPABASE_SERVICE_ROLE_KEY: zod_1.z.string().min(1, 'SUPABASE_SERVICE_ROLE_KEY is required'),
    SUPABASE_JWT_SECRET: zod_1.z.string().min(1, 'SUPABASE_JWT_SECRET is required to verify auth tokens'),
    DEEPSEEK_API_KEY: zod_1.z.string().min(1, 'DEEPSEEK_API_KEY is required'),
    SCAN_API_URL: zod_1.z.string().url().optional().default('https://openrouter.ai/api/v1/chat/completions'),
    SCAN_API_KEY: zod_1.z.string().optional().default(''),
    ALLOW_DEV_USER: zod_1.z.string().optional().default('false'),
    // Dev mode: real Supabase auth user UUID for local testing (must exist in auth.users)
    DEV_USER_ID: zod_1.z.string().uuid().optional(),
    // RAG / Embeddings configuration (optional - RAG disabled if not set)
    OPENAI_API_KEY: zod_1.z.string().optional(),
    OPENAI_BASE_URL: zod_1.z.string().optional().default('https://api.openai.com/v1'),
    EMBEDDING_MODEL: zod_1.z.string().optional().default('text-embedding-3-small'),
});
const parsed = envSchema.safeParse(process.env);
if (!parsed.success) {
    const formatted = parsed.error.errors.map((err) => `${err.path.join('.')}: ${err.message}`).join('; ');
    throw new Error(`Invalid environment configuration: ${formatted}`);
}
exports.env = parsed.data;
// ─────────────────────────────────────────────────────────────────────────────
// DEV MODE DETECTION
// ─────────────────────────────────────────────────────────────────────────────
// Dev mode = NODE_ENV is 'development' OR ALLOW_DEV_USER is explicitly 'true'
const allowDevUser = exports.env.ALLOW_DEV_USER === 'true';
const isDevelopment = exports.env.NODE_ENV === 'development';
const isProduction = exports.env.NODE_ENV === 'production';
exports.isDevMode = isDevelopment || allowDevUser;
/**
 * Dev user ID for local development without JWT auth.
 *
 * IMPORTANT: This should be a REAL Supabase auth user UUID that exists in your
 * auth.users table. Using a fake string like "dev-user-0001" will cause UUID
 * validation errors when querying tables with user_id FK constraints.
 *
 * Set DEV_USER_ID in your .env file to your actual Supabase user UUID.
 * Falls back to a placeholder if not set (will cause errors on FK tables).
 *
 * @example DEV_USER_ID=086d851d-1ae0-4d78-8603-d5707156d896
 */
exports.DEV_USER_ID = exports.env.DEV_USER_ID ?? 'dev-user-0001';
// ─────────────────────────────────────────────────────────────────────────────
// STARTUP LOGGING (Compact)
// ─────────────────────────────────────────────────────────────────────────────
// Only show detailed logs in dev mode
if (exports.isDevMode) {
    console.log('[env] ───────────────────────────────────────────────────');
    console.log('[env] Loaded from:', loadedEnvPath ?? '(none found)');
    console.log('[env] NODE_ENV:', exports.env.NODE_ENV);
    console.log('[env] ALLOW_DEV_USER:', exports.env.ALLOW_DEV_USER);
    console.log('[env] isDevMode:', exports.isDevMode);
    console.log('[env] DEV_USER_ID:', exports.DEV_USER_ID);
    console.log('[env] ───────────────────────────────────────────────────');
    console.log('[env] Keys present:');
    console.log('[env]   SUPABASE_URL:', exports.env.SUPABASE_URL ? '✓' : '✗');
    console.log('[env]   SUPABASE_SERVICE_ROLE_KEY:', exports.env.SUPABASE_SERVICE_ROLE_KEY ? '✓' : '✗');
    console.log('[env]   SUPABASE_JWT_SECRET:', exports.env.SUPABASE_JWT_SECRET ? '✓' : '✗');
    console.log('[env]   DEEPSEEK_API_KEY:', exports.env.DEEPSEEK_API_KEY ? '✓' : '✗');
    console.log('[env]   SCAN_API_KEY:', exports.env.SCAN_API_KEY ? '✓' : '(empty, will use mock)');
    console.log('[env]   OPENAI_API_KEY:', exports.env.OPENAI_API_KEY ? '✓ (RAG enabled)' : '✗ (RAG disabled)');
    console.log('[env]   EMBEDDING_MODEL:', exports.env.EMBEDDING_MODEL);
    console.log('[env] ───────────────────────────────────────────────────');
}
else {
    // Production: minimal log
    console.log('[env] ✓ Environment loaded (production mode)');
}
// SECURITY WARNING: dev mode enabled in production
if (isProduction && allowDevUser) {
    console.error('');
    console.error('╔══════════════════════════════════════════════════════════╗');
    console.error('║  ⚠️  SECURITY WARNING                                    ║');
    console.error('║  ALLOW_DEV_USER=true is set in PRODUCTION!               ║');
    console.error('║  Authentication is BYPASSED. Remove this in production!  ║');
    console.error('╚══════════════════════════════════════════════════════════╝');
    console.error('');
}
//# sourceMappingURL=env.js.map