/**
 * Plate AI Service
 * 
 * Analyzes meal plate images using OpenRouter + Qwen Vision model.
 * Returns structured nutrition analysis with macros, quality rating, and suggestions.
 * 
 * If SCAN_API_KEY is missing, returns a mock result for development.
 */

import axios from 'axios';
import { env } from '../config/env';

// ─────────────────────────────────────────────────────────────────────────────
// TYPES
// ─────────────────────────────────────────────────────────────────────────────

export interface MacroDetail {
  grams: number;
  rating: 'low' | 'medium' | 'high';
}

export interface PlateAnalysisResult {
  success: true;
  source: 'mock' | 'openrouter';
  summary: string;
  qualityLabel: 'A' | 'B' | 'C' | 'D' | 'E';
  calories: {
    estimatedKcal: number;
    confidence: number;
  };
  macros: {
    protein: MacroDetail;
    carbs: MacroDetail;
    fat: MacroDetail;
    fiber: MacroDetail;
  };
  warnings: string[];
  suggestions: string[];
}

export interface PlateAnalysisError {
  success: false;
  error: string;
  debugId: string;
}

export type PlateAnalysisResponse = PlateAnalysisResult | PlateAnalysisError;

// ─────────────────────────────────────────────────────────────────────────────
// MOCK RESULT
// ─────────────────────────────────────────────────────────────────────────────

const MOCK_PLATE_RESULT: PlateAnalysisResult = {
  success: true,
  source: 'mock',
  summary: 'Grilled chicken with rice and salad.',
  qualityLabel: 'B',
  calories: {
    estimatedKcal: 620,
    confidence: 0.6
  },
  macros: {
    protein: { grams: 40, rating: 'high' },
    carbs: { grams: 55, rating: 'medium' },
    fat: { grams: 18, rating: 'medium' },
    fiber: { grams: 7, rating: 'medium' }
  },
  warnings: ['Sodium may be high if seasoned heavily'],
  suggestions: ['Add more leafy greens to boost volume and micronutrients']
};

// ─────────────────────────────────────────────────────────────────────────────
// SYSTEM PROMPT
// ─────────────────────────────────────────────────────────────────────────────

const SYSTEM_PROMPT = `You are a nutrition AI. You receive a single meal photo and must output a strict JSON object describing calories, macros, health quality A–E, warnings, and improvement suggestions.

Your response MUST be a valid JSON object with this exact structure:
{
  "summary": "Brief description of the meal",
  "qualityLabel": "A" | "B" | "C" | "D" | "E",
  "calories": {
    "estimatedKcal": number,
    "confidence": number between 0 and 1
  },
  "macros": {
    "protein": { "grams": number, "rating": "low" | "medium" | "high" },
    "carbs": { "grams": number, "rating": "low" | "medium" | "high" },
    "fat": { "grams": number, "rating": "low" | "medium" | "high" },
    "fiber": { "grams": number, "rating": "low" | "medium" | "high" }
  },
  "warnings": ["array of health warnings if any"],
  "suggestions": ["array of improvement suggestions"]
}

Quality labels:
- A: Excellent - balanced, nutrient-dense, minimal processed foods
- B: Good - mostly healthy with minor improvements possible
- C: Average - some healthy elements but room for improvement
- D: Below average - high in processed foods or unbalanced
- E: Poor - very unhealthy, high sugar/fat, minimal nutrients

Rating guidelines for macros:
- Protein: low (<15g), medium (15-35g), high (>35g)
- Carbs: low (<30g), medium (30-60g), high (>60g)
- Fat: low (<10g), medium (10-25g), high (>25g)
- Fiber: low (<5g), medium (5-10g), high (>10g)

Do NOT include markdown, code blocks, or any text outside the JSON. Output ONLY the JSON object.`;

// ─────────────────────────────────────────────────────────────────────────────
// MAIN FUNCTION
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Analyzes a plate image and returns structured nutrition data.
 * 
 * @param imageBase64 - Base64-encoded image data (without data URL prefix)
 * @param mimeType - Image MIME type (e.g., 'image/jpeg', 'image/png')
 */
export async function analyzePlateImage(
  imageBase64: string,
  mimeType: string = 'image/jpeg'
): Promise<PlateAnalysisResponse> {
  const debugId = `plate-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
  
  // Check if API key is available
  if (!env.SCAN_API_KEY) {
    console.log(`[plate] ${debugId} - Using MOCK result (SCAN_API_KEY not configured)`);
    return MOCK_PLATE_RESULT;
  }

  console.log(`[plate] ${debugId} - Calling OpenRouter Qwen Vision API`);

  try {
    const response = await axios.post(
      env.SCAN_API_URL,
      {
        model: 'qwen/qwen2.5-vl-72b-instruct',
        messages: [
          {
            role: 'system',
            content: SYSTEM_PROMPT
          },
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: 'Analyze this meal and respond with the JSON format I described.'
              },
              {
                type: 'image_url',
                image_url: {
                  url: `data:${mimeType};base64,${imageBase64}`
                }
              }
            ]
          }
        ],
        temperature: 0.4,
        max_tokens: 1000
      },
      {
        headers: {
          'Authorization': `Bearer ${env.SCAN_API_KEY}`,
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://everform.app',
          'X-Title': 'EverForm Plate AI'
        },
        timeout: 60000 // Vision models can be slow
      }
    );

    const content = response.data?.choices?.[0]?.message?.content;
    
    if (!content) {
      console.warn(`[plate] ${debugId} - No content in API response, returning mock`);
      return MOCK_PLATE_RESULT;
    }

    // Parse the JSON response
    // Remove any markdown code blocks if present
    const cleanedContent = content
      .replace(/```json\n?/g, '')
      .replace(/```\n?/g, '')
      .trim();

    let parsed: any;
    try {
      parsed = JSON.parse(cleanedContent);
    } catch (parseErr) {
      console.error(`[plate] ${debugId} - Failed to parse model response:`, cleanedContent.slice(0, 200));
      return {
        success: false,
        error: 'Failed to parse model response as JSON',
        debugId
      };
    }

    // Validate and normalize the response
    const result: PlateAnalysisResult = {
      success: true,
      source: 'openrouter',
      summary: parsed.summary || 'Meal analysis complete',
      qualityLabel: validateQualityLabel(parsed.qualityLabel),
      calories: {
        estimatedKcal: Math.round(parsed.calories?.estimatedKcal ?? 500),
        confidence: Math.min(1, Math.max(0, parsed.calories?.confidence ?? 0.5))
      },
      macros: {
        protein: normalizeMacro(parsed.macros?.protein),
        carbs: normalizeMacro(parsed.macros?.carbs),
        fat: normalizeMacro(parsed.macros?.fat),
        fiber: normalizeMacro(parsed.macros?.fiber)
      },
      warnings: Array.isArray(parsed.warnings) ? parsed.warnings : [],
      suggestions: Array.isArray(parsed.suggestions) ? parsed.suggestions : []
    };

    console.log(`[plate] ${debugId} - Analysis complete: ${result.qualityLabel} grade, ${result.calories.estimatedKcal} kcal`);
    return result;

  } catch (err: any) {
    const errorMessage = err.response?.data?.error?.message || err.message || 'Unknown error';
    console.warn(`[plate] ${debugId} - API error, returning mock:`, errorMessage);
    
    // Return mock on API errors to keep app usable
    return MOCK_PLATE_RESULT;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

function validateQualityLabel(label: any): 'A' | 'B' | 'C' | 'D' | 'E' {
  const valid = ['A', 'B', 'C', 'D', 'E'];
  if (typeof label === 'string' && valid.includes(label.toUpperCase())) {
    return label.toUpperCase() as 'A' | 'B' | 'C' | 'D' | 'E';
  }
  return 'C'; // Default to average
}

function normalizeMacro(macro: any): MacroDetail {
  const grams = typeof macro?.grams === 'number' ? Math.round(macro.grams) : 0;
  const rating = ['low', 'medium', 'high'].includes(macro?.rating) 
    ? macro.rating 
    : 'medium';
  return { grams, rating };
}

