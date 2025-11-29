import axios from 'axios';
import { env } from '../config/env';

type ScanMode = 'calories' | 'ingredients' | 'plate';

interface ScanInput {
  mode: ScanMode;
  imageBase64: string;
}

export interface ScanResponse {
  mode: ScanMode;
  calories?: number;
  protein?: number;
  carbs?: number;
  fat?: number;
  confidence?: number;
  ingredients?: Array<{ name: string; confidence: number }>;
  notes?: string;
  description?: string;
  mealType?: string;
  caloriesEstimate?: number;
}

export async function analyzeImage(input: ScanInput): Promise<ScanResponse> {
  // 1. Check if API keys are present; if not, return mock
  if (!env.SCAN_API_URL || !env.SCAN_API_KEY) {
    console.warn('Scan API key missing, returning mock response.');
    return getMockResponse(input.mode);
  }

  try {
    // 2. Call OpenRouter (Qwen)
    const prompt = getPromptForMode(input.mode);
    
    const response = await axios.post(
      env.SCAN_API_URL, // e.g., https://openrouter.ai/api/v1/chat/completions
      {
        model: 'qwen/qwen-2.5-vl-72b-instruct:free', // Using a capable vision model
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: prompt
              },
              {
                type: 'image_url',
                image_url: {
                  url: `data:image/jpeg;base64,${input.imageBase64}`
                }
              }
            ]
          }
        ]
      },
      {
        headers: {
          'Authorization': `Bearer ${env.SCAN_API_KEY}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000 // Vision models can be slow
      }
    );

    const content = response.data?.choices?.[0]?.message?.content;
    if (!content) throw new Error('No content in response');

    // 3. Parse JSON from the response
    // Qwen might wrap code in markdown blocks
    const jsonString = content.replace(/```json\n?|\n?```/g, '').trim();
    const parsed = JSON.parse(jsonString);

    return {
      mode: input.mode,
      ...parsed
    };

  } catch (err) {
    console.error('Scan analysis failed:', err);
    // Fallback to mock on error to keep app usable
    return getMockResponse(input.mode);
  }
}

function getPromptForMode(mode: ScanMode): string {
  const jsonStructure = getJsonStructure(mode);
  return `Analyze this food image. Return ONLY a valid JSON object matching this structure: ${jsonStructure}. Do not include any other text.`;
}

function getJsonStructure(mode: ScanMode): string {
  switch (mode) {
    case 'calories':
      return `{"calories": number, "protein": number, "carbs": number, "fat": number, "confidence": number (0-1)}`;
    case 'ingredients':
      return `{"ingredients": [{"name": string, "confidence": number}], "notes": string}`;
    case 'plate':
      return `{"description": string, "mealType": string, "caloriesEstimate": number}`;
  }
}

function getMockResponse(mode: ScanMode): ScanResponse {
  switch (mode) {
    case 'calories':
      return {
        mode,
        calories: 550,
        protein: 32,
        carbs: 45,
        fat: 20,
        confidence: 0.89
      };
    case 'ingredients':
      return {
        mode,
        ingredients: [
          { name: 'Grilled Chicken', confidence: 0.95 },
          { name: 'Quinoa', confidence: 0.90 },
          { name: 'Broccoli', confidence: 0.85 }
        ],
        notes: 'Looks like a healthy balanced meal.'
      };
    case 'plate':
      return {
        mode,
        description: 'A balanced plate with lean protein and vegetables.',
        mealType: 'Lunch',
        caloriesEstimate: 600
      };
  }
}
