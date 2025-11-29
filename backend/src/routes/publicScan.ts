/**
 * Public Food Scan API
 *
 * Simplified scan endpoint for the iOS app that returns mock nutrition data.
 * Can be extended to use real vision API when ready.
 *
 * POST /api/scan/food
 */
import { Router, Request, Response } from 'express';
import { z } from 'zod';

const router = Router();

// Request schema matching iOS app expectations
const foodScanSchema = z.object({
  imageUrl: z.string().optional(),
  barcode: z.string().optional(),
  mode: z.enum(['calories', 'ingredients', 'plate']),
});

interface FoodScanResponse {
  item: string;
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  confidence?: number;
  ingredients?: Array<{ name: string; amount?: string }>;
  mealType?: string;
}

// Mock food data for realistic responses
const MOCK_FOODS: Record<string, FoodScanResponse> = {
  default: {
    item: 'Mixed meal',
    calories: 550,
    protein: 32,
    carbs: 45,
    fat: 22,
    confidence: 0.85,
  },
  breakfast: {
    item: 'Breakfast bowl',
    calories: 420,
    protein: 24,
    carbs: 52,
    fat: 14,
    mealType: 'breakfast',
    ingredients: [
      { name: 'Oatmeal', amount: '1 cup' },
      { name: 'Banana', amount: '1 medium' },
      { name: 'Almond butter', amount: '2 tbsp' },
      { name: 'Blueberries', amount: '1/2 cup' },
    ],
  },
  lunch: {
    item: 'Grilled chicken salad',
    calories: 480,
    protein: 42,
    carbs: 28,
    fat: 24,
    mealType: 'lunch',
    ingredients: [
      { name: 'Grilled chicken breast', amount: '6 oz' },
      { name: 'Mixed greens', amount: '2 cups' },
      { name: 'Cherry tomatoes', amount: '1/2 cup' },
      { name: 'Olive oil dressing', amount: '2 tbsp' },
    ],
  },
  dinner: {
    item: 'Salmon with vegetables',
    calories: 620,
    protein: 45,
    carbs: 35,
    fat: 32,
    mealType: 'dinner',
    ingredients: [
      { name: 'Atlantic salmon', amount: '6 oz' },
      { name: 'Roasted broccoli', amount: '1 cup' },
      { name: 'Sweet potato', amount: '1 medium' },
      { name: 'Butter', amount: '1 tbsp' },
    ],
  },
  snack: {
    item: 'Protein snack',
    calories: 280,
    protein: 20,
    carbs: 22,
    fat: 12,
    mealType: 'snack',
    ingredients: [
      { name: 'Greek yogurt', amount: '1 cup' },
      { name: 'Honey', amount: '1 tbsp' },
      { name: 'Walnuts', amount: '1 oz' },
    ],
  },
};

/**
 * Get a mock food response with slight variation for realism
 */
function getMockResponse(mode: string): FoodScanResponse {
  // Randomly select a meal type for variety
  const mealTypes = ['breakfast', 'lunch', 'dinner', 'snack', 'default'];
  const randomMeal = mealTypes[Math.floor(Math.random() * mealTypes.length)];
  const baseMeal = MOCK_FOODS[randomMeal] || MOCK_FOODS.default;

  // Add slight variation (±10%) for realism
  const variation = 0.9 + Math.random() * 0.2;

  return {
    ...baseMeal,
    calories: Math.round(baseMeal.calories * variation),
    protein: Math.round(baseMeal.protein * variation),
    carbs: Math.round(baseMeal.carbs * variation),
    fat: Math.round(baseMeal.fat * variation),
    confidence: Number((0.75 + Math.random() * 0.2).toFixed(2)),
  };
}

/**
 * POST /api/scan/food
 *
 * Request body:
 * {
 *   "imageUrl"?: string,
 *   "barcode"?: string,
 *   "mode": "calories" | "ingredients" | "plate"
 * }
 *
 * Response:
 * {
 *   "item": "Mock meal",
 *   "calories": 550,
 *   "protein": 32,
 *   "carbs": 45,
 *   "fat": 22
 * }
 */
router.post('/food', async (req: Request, res: Response) => {
  try {
    // Validate request body
    const parseResult = foodScanSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        error: 'Invalid request body',
        details: parseResult.error.issues,
        expected: {
          imageUrl: 'optional string',
          barcode: 'optional string',
          mode: 'required: "calories" | "ingredients" | "plate"',
        },
      });
    }

    const { mode, imageUrl, barcode } = parseResult.data;

    // Log the scan request (without exposing full image data)
    console.log(
      `[scan/food] mode=${mode}, hasImage=${!!imageUrl}, barcode=${barcode ?? 'none'}`
    );

    // Return mock response
    // In production, this would call the vision API via scanService
    const mockResponse = getMockResponse(mode);

    return res.json(mockResponse);
  } catch (err) {
    console.error('[scan/food] Error:', err);

    const errorMessage =
      err instanceof Error ? err.message : 'An unexpected error occurred';

    return res.status(500).json({
      error: 'Failed to analyze food',
      message: errorMessage,
    });
  }
});

/**
 * GET /api/scan/test
 *
 * Quick test endpoint to verify the scan API is working
 */
router.get('/test', (_req: Request, res: Response) => {
  res.json({
    ok: true,
    message: 'Scan API is ready',
    modes: ['calories', 'ingredients', 'plate'],
  });
});

export default router;

