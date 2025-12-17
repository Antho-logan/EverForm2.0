/**
 * Vision Service
 * 
 * Handles real AI vision analysis using OpenRouter API.
 * Falls back to mock data if API is not configured or fails.
 * 
 * USAGE:
 *   import { analyzeFood } from './visionService';
 *   const result = await analyzeFood({ mode: 'calories', imageBase64: '...' });
 * 
 * ENVIRONMENT:
 *   - SCAN_API_URL: OpenRouter API endpoint (default: https://openrouter.ai/api/v1/chat/completions)
 *   - SCAN_API_KEY: OpenRouter API key (required for real analysis)
 */

import axios from 'axios';
import { env } from '../config/env';

// ─────────────────────────────────────────────────────────────────────────────
// TYPES
// ─────────────────────────────────────────────────────────────────────────────

export type ScanMode = 'calories' | 'ingredients' | 'plate';

export interface VisionInput {
  mode: ScanMode;
  imageBase64: string;
}

export interface ScanIngredient {
  name: string;
  confidence: number;
}

export interface VisionAnalysis {
  mode: string;
  calories: number | null;
  protein: number | null;
  carbs: number | null;
  fat: number | null;
  confidence: number | null;
  ingredients: ScanIngredient[] | null;
  notes: string | null;
  description: string | null;
  mealType: string | null;
  caloriesEstimate: number | null;
  // Extended Plate AI fields
  dishName: string | null;
  shortDescription: string | null;
  fiber: number | null;
  healthGrade: string | null;
  warnings: string[] | null;
  suggestions: string[] | null;
}

export interface VisionResult {
  analysis: VisionAnalysis;
  source: 'ai' | 'mock';
  success: boolean;
}

// ─────────────────────────────────────────────────────────────────────────────
// PROMPTS
// ─────────────────────────────────────────────────────────────────────────────

function getSystemPrompt(mode: ScanMode): string {
  if (mode === 'plate') {
    return `You are a nutrition analysis AI that analyzes food images. Your job is to:
1. FIRST, carefully identify what food is ACTUALLY visible in the image.
2. NEVER guess or hallucinate foods that are not clearly visible.
3. If you see a dessert (cake, pie, pastry, cookies, ice cream), describe it as a dessert.
4. If you see a savory meal (chicken, rice, salad), describe it as such.
5. If uncertain about what the food is, say "unidentified food item" rather than guessing incorrectly.
6. Base ALL your analysis ONLY on what you can visually confirm in the image.
7. Return ONLY valid JSON with no additional text, markdown, or explanation.`;
  }
  return `You are a nutrition analysis AI. Analyze the food image and return ONLY a valid JSON object with no additional text, markdown, or explanation.`;
}

function getUserPrompt(mode: ScanMode): string {
  switch (mode) {
    case 'calories':
      return `Analyze this food image and estimate its nutritional content.
Return ONLY this JSON structure (no other text):
{
  "calories": <number: estimated total calories>,
  "protein": <number: grams of protein>,
  "carbs": <number: grams of carbohydrates>,
  "fat": <number: grams of fat>,
  "confidence": <number: 0.0 to 1.0 confidence in your estimate>,
  "description": "<string: brief description of the food>"
}`;

    case 'ingredients':
      return `Identify the ingredients visible in this food image.
Return ONLY this JSON structure (no other text):
{
  "ingredients": [
    { "name": "<string: ingredient name>", "confidence": <number: 0.0 to 1.0> }
  ],
  "notes": "<string: brief notes about the meal>"
}
List the most prominent ingredients first, with confidence scores.`;

    case 'plate':
      return `IMPORTANT: Look carefully at this image and describe ONLY what you actually see.

Step 1: What type of food is this? (e.g., dessert, main course, snack, beverage)
Step 2: Describe the specific food item(s) visible.
Step 3: Estimate nutritional content based on what you identified.

If this is a dessert (cake, pie, pastry, etc.), say so clearly.
If this is a savory meal, describe the actual components.
Do NOT guess "grilled chicken with rice" if you see cake or any other dessert.

Return ONLY this JSON structure (no other text):
{
  "dishName": "<string: specific name of the dish, e.g., 'chocolate cake slice', 'grilled salmon with vegetables'>",
  "shortDescription": "<string: 1-2 sentence description of what you see>",
  "mealType": "<string: Breakfast, Lunch, Dinner, Snack, or Dessert>",
  "estimatedCalories": <number: estimated total calories>,
  "macros": {
    "protein": <number: grams>,
    "carbs": <number: grams>,
    "fat": <number: grams>,
    "fiber": <number: grams>
  },
  "healthGrade": "<string: A, B, C, D, or E based on nutritional quality>",
  "warnings": ["<string: health warnings if any, e.g., 'High in sugar'>"],
  "suggestions": ["<string: improvement suggestions>"]
}`;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────────────────────────────────────

function getMockAnalysis(mode: ScanMode): VisionAnalysis {
  // Add variation for realism
  const v = 0.85 + Math.random() * 0.3;
  
  // Base fields that are null for most modes
  const baseFields = {
    dishName: null,
    shortDescription: null,
    fiber: null,
    healthGrade: null,
    warnings: null,
    suggestions: null,
  };
  
  switch (mode) {
    case 'calories':
      return {
        ...baseFields,
        mode: 'calories',
        calories: Math.round(480 * v),
        protein: Math.round(28 * v),
        carbs: Math.round(45 * v),
        fat: Math.round(16 * v),
        confidence: Number((0.65 + Math.random() * 0.2).toFixed(2)),
        ingredients: null,
        notes: 'Vision API not configured. Showing estimated values.',
        description: 'Estimated meal analysis',
        mealType: null,
        caloriesEstimate: null,
      };

    case 'ingredients':
      return {
        ...baseFields,
        mode: 'ingredients',
        calories: null,
        protein: null,
        carbs: null,
        fat: null,
        confidence: null,
        ingredients: [
          { name: 'Main protein source', confidence: 0.7 },
          { name: 'Carbohydrate component', confidence: 0.65 },
          { name: 'Vegetable/fiber', confidence: 0.6 },
        ],
        notes: 'Vision API not configured. Showing placeholder ingredients.',
        description: null,
        mealType: null,
        caloriesEstimate: null,
      };

    case 'plate':
      return {
        mode: 'plate',
        calories: null,
        protein: Math.round(25 * v),
        carbs: Math.round(50 * v),
        fat: Math.round(20 * v),
        confidence: null,
        ingredients: null,
        notes: null,
        description: 'Vision API not configured. Unable to analyze plate composition.',
        mealType: 'Meal',
        caloriesEstimate: Math.round(500 * v),
        dishName: 'Unknown dish',
        shortDescription: 'Vision API not configured. Showing placeholder data.',
        fiber: Math.round(5 * v),
        healthGrade: 'C',
        warnings: ['Unable to analyze - showing estimated values'],
        suggestions: ['Import a photo for accurate analysis'],
      };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN FUNCTION
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Analyzes a food image using AI vision.
 * Falls back to mock data if API is not configured or fails.
 */
export async function analyzeFood(input: VisionInput): Promise<VisionResult> {
  const { mode, imageBase64 } = input;
  const debugId = `vision-${Date.now()}`;
  
  // Check if API is configured
  // Note: env.SCAN_API_KEY defaults to '' if not set, so check for empty string too
  const apiKey = env.SCAN_API_KEY;
  if (!apiKey || apiKey.trim() === '') {
    console.log(`[vision] ${debugId} - No SCAN_API_KEY configured (key length: ${apiKey?.length ?? 0}), returning mock for ${mode}`);
    return {
      analysis: getMockAnalysis(mode),
      source: 'mock',
      success: true,
    };
  }
  
  console.log(`[vision] ${debugId} - API key present (length: ${apiKey.length}), proceeding with real AI call`);

  const imageSizeKB = Math.round(imageBase64.length / 1024);
  
  // Ensure we're calling the chat completions endpoint
  // Handle both "https://openrouter.ai/api/v1" and "https://openrouter.ai/api/v1/chat/completions"
  let apiUrl = env.SCAN_API_URL;
  if (!apiUrl.endsWith('/chat/completions')) {
    apiUrl = apiUrl.replace(/\/$/, '') + '/chat/completions';
  }
  
  console.log(`[vision] ${debugId} - Calling OpenRouter for ${mode} analysis (${imageSizeKB}KB image)`);
  console.log(`[vision] ${debugId} - API URL: ${apiUrl}`);

  try {
    const response = await axios.post(
      apiUrl,
      {
        model: 'qwen/qwen2.5-vl-72b-instruct',
        messages: [
          {
            role: 'system',
            content: getSystemPrompt(mode),
          },
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: getUserPrompt(mode),
              },
              {
                type: 'image_url',
                image_url: {
                  url: `data:image/jpeg;base64,${imageBase64}`,
                },
              },
            ],
          },
        ],
        temperature: 0.3,
        max_tokens: 500,
      },
      {
        headers: {
          'Authorization': `Bearer ${env.SCAN_API_KEY}`,
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://everform.app',
          'X-Title': 'EverForm Food Scanner',
        },
        timeout: 45000, // Vision models can be slow
      }
    );

    const choice = response.data?.choices?.[0];
    const content = choice?.message?.content;
    const finishReason = choice?.finish_reason;
    
    if (!content || content.trim() === '') {
      // Model returned empty content - could be due to invalid/tiny image, content policy, etc.
      const reason = finishReason || 'unknown';
      console.warn(`[vision] ${debugId} - Empty content from API (finish_reason: ${reason}). Image may be invalid or too small.`);
      return {
        analysis: getMockAnalysis(mode),
        source: 'mock',
        success: true,
      };
    }

    // Parse JSON from response (handle markdown code blocks)
    const cleanedContent = content
      .replace(/```json\n?/g, '')
      .replace(/```\n?/g, '')
      .trim();

    let parsed: any;
    try {
      parsed = JSON.parse(cleanedContent);
    } catch (parseErr) {
      console.warn(`[vision] ${debugId} - Failed to parse JSON:`, cleanedContent.slice(0, 100));
      return {
        analysis: getMockAnalysis(mode),
        source: 'mock',
        success: true,
      };
    }

    // Map parsed response to our analysis structure
    const analysis = mapToAnalysis(mode, parsed);
    
    console.log(`[vision] ${debugId} - AI analysis complete for ${mode}`);
    
    return {
      analysis,
      source: 'ai',
      success: true,
    };

  } catch (err: any) {
    // Detailed error logging for debugging
    const statusCode = err.response?.status;
    const errorMsg = err.response?.data?.error?.message || err.message || 'Unknown error';
    const errorData = err.response?.data;
    
    console.error(`[vision] ${debugId} - API error details:`);
    console.error(`  - Status: ${statusCode || 'N/A'}`);
    console.error(`  - Message: ${errorMsg}`);
    if (errorData && typeof errorData === 'object') {
      console.error(`  - Response data:`, JSON.stringify(errorData).slice(0, 500));
    }
    
    return {
      analysis: getMockAnalysis(mode),
      source: 'mock',
      success: true,
    };
  }
}

/**
 * Maps the raw AI response to our standard analysis structure.
 */
function mapToAnalysis(mode: ScanMode, parsed: any): VisionAnalysis {
  // Base fields that are null for most modes
  const baseFields = {
    dishName: null,
    shortDescription: null,
    fiber: null,
    healthGrade: null,
    warnings: null,
    suggestions: null,
  };

  switch (mode) {
    case 'calories':
      return {
        ...baseFields,
        mode: 'calories',
        calories: typeof parsed.calories === 'number' ? Math.round(parsed.calories) : null,
        protein: typeof parsed.protein === 'number' ? Math.round(parsed.protein) : null,
        carbs: typeof parsed.carbs === 'number' ? Math.round(parsed.carbs) : null,
        fat: typeof parsed.fat === 'number' ? Math.round(parsed.fat) : null,
        confidence: typeof parsed.confidence === 'number' ? Math.min(1, Math.max(0, parsed.confidence)) : null,
        ingredients: null,
        notes: null,
        description: parsed.description || null,
        mealType: null,
        caloriesEstimate: null,
      };

    case 'ingredients': {
      const ingredients = Array.isArray(parsed.ingredients)
        ? parsed.ingredients.map((i: any) => ({
            name: String(i.name || 'Unknown'),
            confidence:
              typeof i.confidence === 'number' ? Math.min(1, Math.max(0, i.confidence)) : 0.5,
          }))
        : null;

      return {
        ...baseFields,
        mode: 'ingredients',
        calories: null,
        protein: null,
        carbs: null,
        fat: null,
        confidence: null,
        ingredients,
        notes: parsed.notes || null,
        description: null,
        mealType: null,
        caloriesEstimate: null,
      };
    }

    case 'plate': {
      // Extract macros from nested object if present
      const macros = parsed.macros || {};
      const protein = typeof macros.protein === 'number' ? macros.protein : null;
      const carbs = typeof macros.carbs === 'number' ? macros.carbs : null;
      const fat = typeof macros.fat === 'number' ? macros.fat : null;
      const fiber = typeof macros.fiber === 'number' ? macros.fiber : null;
      
      // Validate warnings and suggestions are arrays of strings
      const warnings = Array.isArray(parsed.warnings) 
        ? parsed.warnings.filter((w: any) => typeof w === 'string')
        : null;
      const suggestions = Array.isArray(parsed.suggestions)
        ? parsed.suggestions.filter((s: any) => typeof s === 'string')
        : null;
      
      // Use dishName + shortDescription for description if available
      const description = parsed.shortDescription || parsed.description || null;
      
      // Debug logging for plate mode (only in non-production)
      if (process.env.NODE_ENV !== 'production') {
        console.log(`[vision] Plate AI raw response (truncated):`, JSON.stringify(parsed).slice(0, 300));
      }
      
      return {
        mode: 'plate',
        calories: null,
        protein,
        carbs,
        fat,
        confidence: null,
        ingredients: null,
        notes: null,
        description,
        mealType: parsed.mealType || null,
        caloriesEstimate: typeof parsed.estimatedCalories === 'number' 
          ? Math.round(parsed.estimatedCalories) 
          : (typeof parsed.caloriesEstimate === 'number' ? Math.round(parsed.caloriesEstimate) : null),
        dishName: parsed.dishName || null,
        shortDescription: parsed.shortDescription || null,
        fiber,
        healthGrade: typeof parsed.healthGrade === 'string' ? parsed.healthGrade.toUpperCase() : null,
        warnings,
        suggestions,
      };
    }

    default:
      return getMockAnalysis(mode);
  }
}

