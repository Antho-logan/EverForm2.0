/**
 * Public Coach Chat API
 *
 * Simplified chat endpoint for the iOS app that doesn't require authentication.
 * Uses the DeepSeek API for LLM responses.
 *
 * POST /api/coach/chat
 */
import { Router, Request, Response } from 'express';
import { z } from 'zod';
import axios from 'axios';
import { env } from '../config/env';

const router = Router();

// Request schema matching iOS app expectations
const chatRequestSchema = z.object({
  messages: z.array(
    z.object({
      role: z.enum(['user', 'assistant', 'system']),
      content: z.string(),
    })
  ),
});

// DeepSeek API endpoint
const DEEPSEEK_URL = 'https://api.deepseek.com/v1/chat/completions';

// Default system prompt for EverForm coach
const DEFAULT_SYSTEM_PROMPT = `You are EverForm, a knowledgeable and empathetic fitness and biohacking coach.
Keep answers concise (under 3 sentences unless detailed explanation is asked).
Be motivating but realistic. Focus on evidence-based advice.`;

interface ChatResponse {
  reply: string;
  usage: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  } | null;
}

/**
 * POST /api/coach/chat
 *
 * Request body:
 * {
 *   "messages": [
 *     { "role": "user" | "assistant" | "system", "content": "..." }
 *   ]
 * }
 *
 * Response:
 * {
 *   "reply": "<assistant_text>",
 *   "usage": { prompt_tokens, completion_tokens, total_tokens } | null
 * }
 */
router.post('/chat', async (req: Request, res: Response) => {
  try {
    // Validate request body
    const parseResult = chatRequestSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        error: 'Invalid request body',
        details: parseResult.error.issues,
      });
    }

    const { messages } = parseResult.data;

    // Add system prompt if not provided
    const hasSystemPrompt = messages.some((m) => m.role === 'system');
    const fullMessages = hasSystemPrompt
      ? messages
      : [{ role: 'system' as const, content: DEFAULT_SYSTEM_PROMPT }, ...messages];

    // Check for API key
    if (!env.DEEPSEEK_API_KEY) {
      console.warn('[coach/chat] No DEEPSEEK_API_KEY configured, returning echo response');
      const lastUserMessage = messages.filter((m) => m.role === 'user').pop();
      return res.json({
        reply: `Echo: ${lastUserMessage?.content ?? 'No message'}`,
        usage: null,
      } satisfies ChatResponse);
    }

    // Call DeepSeek API
    try {
      const response = await axios.post(
        DEEPSEEK_URL,
        {
          model: 'deepseek-chat',
          messages: fullMessages,
        },
        {
          headers: {
            Authorization: `Bearer ${env.DEEPSEEK_API_KEY}`,
            'Content-Type': 'application/json',
          },
          timeout: 30000,
        }
      );

      const content = response.data?.choices?.[0]?.message?.content;
      const usage = response.data?.usage ?? null;

      if (content) {
        return res.json({
          reply: content,
          usage,
        } satisfies ChatResponse);
      }
    } catch (apiErr) {
      // Log the API error but continue to fallback
      console.warn('[coach/chat] DeepSeek API error, using fallback:', 
        apiErr instanceof Error ? apiErr.message : 'Unknown error');
    }

    // Fallback response when API fails
    const lastUserMessage = messages.filter((m) => m.role === 'user').pop();
    const fallbackReplies = [
      "I'm having trouble connecting to my full capabilities right now, but I'm here to help! Could you rephrase that?",
      "Let me give you a quick tip: consistency beats intensity. Start small, stay committed, and results will follow.",
      "While I'm reconnecting, remember: proper sleep, hydration, and nutrition are the foundation of any fitness goal.",
      "I'm experiencing a brief hiccup, but here's what I know: listen to your body, it knows more than any app.",
    ];
    const randomFallback = fallbackReplies[Math.floor(Math.random() * fallbackReplies.length)];

    return res.json({
      reply: randomFallback,
      usage: null,
    } satisfies ChatResponse);
  } catch (err) {
    console.error('[coach/chat] Error:', err);

    // Return friendly error response
    return res.status(500).json({
      error: 'Failed to process chat request',
      message: 'An unexpected error occurred. Please try again.',
    });
  }
});

export default router;

