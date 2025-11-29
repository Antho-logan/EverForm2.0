"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.env = void 0;
// Loads and validates environment variables for the backend.
const dotenv_1 = __importDefault(require("dotenv"));
const zod_1 = require("zod");
dotenv_1.default.config();
const envSchema = zod_1.z.object({
    PORT: zod_1.z.coerce.number().default(4000),
    SUPABASE_URL: zod_1.z.string().url({ message: 'SUPABASE_URL must be a valid URL' }),
    SUPABASE_SERVICE_ROLE_KEY: zod_1.z
        .string()
        .min(1, 'SUPABASE_SERVICE_ROLE_KEY is required'),
    SUPABASE_JWT_SECRET: zod_1.z
        .string()
        .min(1, 'SUPABASE_JWT_SECRET is required to verify auth tokens'),
    DEEPSEEK_API_KEY: zod_1.z.string().min(1, 'DEEPSEEK_API_KEY is required'),
    SCAN_API_URL: zod_1.z.string().url({ message: 'SCAN_API_URL must be a valid URL' }),
    SCAN_API_KEY: zod_1.z.string().min(1, 'SCAN_API_KEY is required')
});
const parsed = envSchema.safeParse(process.env);
if (!parsed.success) {
    const formatted = parsed.error.errors.map((err) => `${err.path.join('.')}: ${err.message}`).join('; ');
    throw new Error(`Invalid environment configuration: ${formatted}`);
}
exports.env = parsed.data;
//# sourceMappingURL=env.js.map