/**
 * Food Scan API
 *
 * Accepts image + mode from iOS app and analyzes food using AI vision.
 * Now requires authentication and includes rate limiting.
 *
 * ENDPOINTS:
 * - POST /api/scan/food   - Food analysis (JSON body with base64 image)
 * - GET  /api/scan/test   - Health check for scan API
 */
import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { env } from '../config/env';
import { analyzeFood, ScanMode, VisionAnalysis } from '../services/visionService';
import { authMiddleware } from '../middleware/auth';
import { scanLimiter } from '../middleware/rateLimit';

const router = Router();

// Apply auth to all routes, rate limiting to specific endpoints
router.use(authMiddleware);

// ─────────────────────────────────────────────────────────────────────────────
// SCHEMAS
// ─────────────────────────────────────────────────────────────────────────────

const foodScanSchema = z.object({
  mode: z.enum(['calories', 'ingredients', 'plate']),
  imageBase64: z.string().min(1).optional(),
  imageUrl: z.string().optional(),
  barcode: z.string().optional(),
});

// ─────────────────────────────────────────────────────────────────────────────
// RESPONSE TYPES
// ─────────────────────────────────────────────────────────────────────────────

interface ScanMeal {
  id: string;
  title: string;
  kcal: number | null;
  protein_g: number | null;
  carbs_g: number | null;
  fat_g: number | null;
  logged_at: string;
}

interface ScanFoodResponse {
  meal: ScanMeal | null;
  analysis: VisionAnalysis;
  status: 'ok' | 'fallback' | 'error';
  success: boolean;
  summary?: string;
  source?: 'ai' | 'mock';
}

// ─────────────────────────────────────────────────────────────────────────────
// FALLBACK MOCK
// ─────────────────────────────────────────────────────────────────────────────

function getValidationFallback(mode: string): VisionAnalysis {
  const v = 0.85 + Math.random() * 0.3;
  
  return {
    mode,
    calories: mode === 'calories' ? Math.round(450 * v) : null,
    protein: mode === 'calories' ? Math.round(25 * v) : null,
    carbs: mode === 'calories' ? Math.round(40 * v) : null,
    fat: mode === 'calories' ? Math.round(15 * v) : null,
    confidence: mode === 'calories' ? 0.5 : null,
    ingredients: mode === 'ingredients' ? [
      { name: 'Food item (no image provided)', confidence: 0.5 },
    ] : null,
    notes: 'No image was provided. Showing placeholder data.',
    description: mode === 'plate' ? 'No image was provided for analysis.' : null,
    mealType: mode === 'plate' ? 'Meal' : null,
    caloriesEstimate: mode === 'plate' ? Math.round(450 * v) : null,
    dishName: mode === 'plate' ? 'Unknown dish' : null,
    shortDescription: mode === 'plate' ? 'No image provided for analysis.' : null,
    fiber: null,
    healthGrade: null,
    warnings: null,
    suggestions: null,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// ROUTES
// ─────────────────────────────────────────────────────────────────────────────

/**
 * POST /api/scan/food
 * Rate limited to 10 requests/minute
 */
router.post('/food', scanLimiter, async (req: Request, res: Response) => {
  const debugId = `scan-${Date.now()}`;
  
  try {
    const parseResult = foodScanSchema.safeParse(req.body);
    
    if (!parseResult.success) {
      console.log(`[scan/food] ${debugId} - Invalid request body:`, parseResult.error.issues);
      
      return res.json({
        meal: null,
        analysis: getValidationFallback('calories'),
        status: 'fallback',
        success: false,
        summary: 'Invalid request format. Please try again.',
        source: 'mock',
      } as ScanFoodResponse);
    }

    const { mode, imageBase64, barcode } = parseResult.data;
    
    const imageSize = imageBase64 ? Math.round(imageBase64.length / 1024) : 0;
    console.log(`[scan/food] ${debugId} - mode=${mode}, imageSize=${imageSize}KB, hasBarcode=${!!barcode}`);

    if (!imageBase64 || imageBase64.length < 100) {
      console.log(`[scan/food] ${debugId} - No valid image (length: ${imageBase64?.length ?? 0}), returning fallback`);
      
      return res.json({
        meal: null,
        analysis: getValidationFallback(mode),
        status: 'fallback',
        success: false,
        summary: 'No image provided. Please import a photo.',
        source: 'mock',
      } as ScanFoodResponse);
    }

    console.log(`[scan/food] ${debugId} - Calling analyzeFood with mode=${mode}`);
    
    const result = await analyzeFood({
      mode: mode as ScanMode,
      imageBase64,
    });
    
    console.log(`[scan/food] ${debugId} - Analysis complete: source=${result.source}`);

    const response: ScanFoodResponse = {
      meal: null,
      analysis: result.analysis,
      status: 'ok',
      success: true,
      summary: `Successfully analyzed ${mode === 'plate' ? 'plate' : mode === 'ingredients' ? 'ingredients' : 'nutrition'}`,
      source: result.source,
    };

    return res.json(response);

  } catch (err) {
    console.error(`[scan/food] ${debugId} - Unexpected error:`, err);

    return res.json({
      meal: null,
      analysis: getValidationFallback('calories'),
      status: 'fallback',
      success: false,
      summary: 'Scan service is temporarily unavailable. Please try again later.',
      source: 'mock',
    } as ScanFoodResponse);
  }
});

/**
 * GET /api/scan/test
 * Health check (no rate limit)
 */
router.get('/test', (_req: Request, res: Response) => {
  res.json({
    ok: true,
    message: 'Scan API is ready',
    modes: ['calories', 'ingredients', 'plate'],
    hasVisionApi: !!env.SCAN_API_KEY,
    visionModel: env.SCAN_API_KEY ? 'qwen/qwen2.5-vl-72b-instruct' : 'none (mock mode)',
  });
});

export default router;
