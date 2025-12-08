/**
 * Public Coach Chat API
 *
 * Chat endpoint for the iOS app.
 * Now requires authentication and includes rate limiting.
 *
 * POST /api/coach/chat
 */
import { Router, Request, Response } from 'express';
import { z } from 'zod';
import axios from 'axios';
import { env } from '../config/env';
import { authMiddleware } from '../middleware/auth';
import { aiChatLimiter } from '../middleware/rateLimit';
import { getKnowledgeContext } from '../services/knowledgeService';
import { sanitizePrompt, sanitizeMessages } from '../utils/promptSanitizer';

const router = Router();

// Apply auth and rate limiting to all routes
router.use(authMiddleware);
router.use(aiChatLimiter);

// Request schema matching iOS app expectations
const chatRequestSchema = z.object({
  messages: z.array(
    z.object({
      role: z.enum(['user', 'assistant', 'system']),
      content: z.string(),
    })
  ).optional(),
  prompt: z.string().optional(),
}).refine(
  (data) => data.messages !== undefined || data.prompt !== undefined,
  { message: 'Either messages or prompt must be provided' }
);

const DEEPSEEK_URL = 'https://api.deepseek.com/v1/chat/completions';

const DEFAULT_SYSTEM_PROMPT = `You are EverForm, a knowledgeable and empathetic fitness and biohacking coach.
Keep answers concise (under 3 sentences unless detailed explanation is asked).
Be motivating but realistic. Focus on evidence-based advice.`;

const NO_KNOWLEDGE_ADDENDUM = `\n\nNote: No internal knowledge documents are available for this question. Answer based on general coaching principles and evidence-based fitness/health guidance.`;

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
 */
router.post('/chat', async (req: Request, res: Response) => {
  try {
    const parseResult = chatRequestSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({
        error: 'Invalid request body',
        details: parseResult.error.issues,
      });
    }

    const { messages: rawMessages, prompt: rawPrompt } = parseResult.data;
    
    // Sanitize prompt to remove extra quotes, braces, JSON wrappers, etc.
    const cleanPrompt = rawPrompt ? sanitizePrompt(rawPrompt) : '';
    
    // Build messages array, sanitizing user message content
    const rawMsgArray = rawMessages ?? (cleanPrompt ? [{ role: 'user' as const, content: cleanPrompt }] : []);
    const messages = sanitizeMessages(rawMsgArray);
    
    if (messages.length === 0) {
      return res.status(400).json({
        error: 'No messages provided',
        message: 'Please provide either a messages array or a prompt string.',
      });
    }

    // Extract the last user message for RAG lookup
    const lastUserMessage = messages.filter((m) => m.role === 'user').pop()?.content ?? '';

    // Attempt RAG lookup for knowledge-based questions
    let knowledgeContext: string | null = null;
    try {
      knowledgeContext = await getKnowledgeContext(lastUserMessage);
      if (knowledgeContext) {
        console.log('[coach/chat] RAG: Found relevant knowledge chunks');
      }
    } catch (ragErr) {
      console.warn('[coach/chat] RAG lookup failed, continuing without knowledge context:', ragErr);
    }

    // Build system prompt with optional knowledge context
    const hasSystemPrompt = messages.some((m) => m.role === 'system');
    let systemContent = hasSystemPrompt 
      ? messages.find((m) => m.role === 'system')!.content 
      : DEFAULT_SYSTEM_PROMPT;

    // Inject knowledge context or add fallback note
    if (knowledgeContext) {
      systemContent = `${systemContent}\n\n---\n\n${knowledgeContext}\n\n---\n\nUse the above knowledge to inform your response when relevant. Cite specific information from the excerpts when applicable.`;
    } else if (lastUserMessage.length > 30) {
      // Only add fallback note for substantial questions
      systemContent = `${systemContent}${NO_KNOWLEDGE_ADDENDUM}`;
    }

    const fullMessages = hasSystemPrompt
      ? [{ role: 'system' as const, content: systemContent }, ...messages.filter((m) => m.role !== 'system')]
      : [{ role: 'system' as const, content: systemContent }, ...messages];

    if (!env.DEEPSEEK_API_KEY) {
      console.warn('[coach/chat] No DEEPSEEK_API_KEY configured');
      const lastUserMessage = messages.filter((m) => m.role === 'user').pop();
      return res.json({
        reply: `Echo: ${lastUserMessage?.content ?? 'No message'}`,
        usage: null,
      } satisfies ChatResponse);
    }

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
      console.warn('[coach/chat] DeepSeek API error:', 
        apiErr instanceof Error ? apiErr.message : 'Unknown error');
    }

    // Fallback when API fails
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
    return res.status(500).json({
      error: 'Failed to process chat request',
      message: 'An unexpected error occurred. Please try again.',
    });
  }
});

export default router;
