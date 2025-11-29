// Loads and validates environment variables for the backend.
import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const envSchema = z.object({
  PORT: z.coerce.number().default(4000),
  SUPABASE_URL: z.string().url({ message: 'SUPABASE_URL must be a valid URL' }),
  SUPABASE_SERVICE_ROLE_KEY: z
    .string()
    .min(1, 'SUPABASE_SERVICE_ROLE_KEY is required'),
  SUPABASE_JWT_SECRET: z
    .string()
    .min(1, 'SUPABASE_JWT_SECRET is required to verify auth tokens'),
  DEEPSEEK_API_KEY: z.string().min(1, 'DEEPSEEK_API_KEY is required'),
  SCAN_API_URL: z.string().url({ message: 'SCAN_API_URL must be a valid URL' }),
  SCAN_API_KEY: z.string().min(1, 'SCAN_API_KEY is required')
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  const formatted = parsed.error.errors.map((err) => `${err.path.join('.')}: ${err.message}`).join('; ');
  throw new Error(`Invalid environment configuration: ${formatted}`);
}

export const env = parsed.data;
