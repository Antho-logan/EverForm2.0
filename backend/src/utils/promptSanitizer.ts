/**
 * Prompt Sanitizer
 * 
 * Cleans up messy user input (extra quotes, curly braces, JSON wrappers)
 * before sending to the AI coach. Ensures the LLM receives clean natural-language text.
 */

/**
 * Sanitizes a raw prompt string by removing JSON wrappers, extra quotes,
 * trailing garbage characters, and other common issues.
 * 
 * @param raw - The raw input string (possibly malformed)
 * @returns Clean natural-language string (never throws, never null)
 */
export function sanitizePrompt(raw: unknown): string {
  // 1) Coerce to string and trim whitespace
  let s = String(raw ?? '').trim();

  if (!s) return '';

  // 2) If it looks like JSON with a "prompt" or "message" field, try to parse it
  //    e.g. '{"prompt":"..."}' or "{ 'prompt': '...' }"
  if (s.startsWith('{') && (s.endsWith('}') || s.includes('}'))) {
    try {
      const cleanedJson = s
        // Normalize single quotes → double quotes for JSON.parse
        .replace(/'/g, '"')
        // Remove trailing garbage like "}'" or '"}' if present
        .replace(/["']?\}\s*['"]?$/g, '}')
        // Handle cases where closing brace is missing
        .replace(/["']+$/g, '');

      // Ensure we have valid-looking JSON
      const jsonCandidate = cleanedJson.endsWith('}') ? cleanedJson : cleanedJson + '}';
      const parsed = JSON.parse(jsonCandidate);

      // Check for common field names
      if (typeof parsed.prompt === 'string') {
        return sanitizePrompt(parsed.prompt); // Recursively sanitize the extracted value
      }
      if (typeof parsed.message === 'string') {
        return sanitizePrompt(parsed.message);
      }
      if (typeof parsed.content === 'string') {
        return sanitizePrompt(parsed.content);
      }
    } catch {
      // JSON parse failed – fall through to string cleaning
    }
  }

  // 3) Strip obvious wrapping characters from both ends
  //    Leading: quotes, braces, whitespace
  //    Trailing: quotes, braces, whitespace
  s = s.replace(/^[\s"'{[]+/, '').replace(/[\s"'}\]]+$/, '');

  // 4) Remove common trailing patterns like `"}'`, `'"}'`, `}'`, `'}`
  s = s.replace(/["']?\}['"]?$/g, '').trim();
  s = s.replace(/['"]?\}["']?$/g, '').trim();

  // 5) Remove trailing orphan quotes or braces
  s = s.replace(/['"}\]]+$/g, '').trim();

  // 6) Remove leading orphan quotes or braces (if any remain)
  s = s.replace(/^['"{[]+/g, '').trim();

  return s;
}

/**
 * Sanitizes message content within a messages array.
 * Used for chat endpoints that accept an array of messages.
 * 
 * @param messages - Array of chat messages
 * @returns New array with sanitized content (only user messages are sanitized)
 */
export function sanitizeMessages<T extends { role: string; content: string }>(
  messages: T[]
): T[] {
  return messages.map((msg) => {
    if (msg.role === 'user') {
      return { ...msg, content: sanitizePrompt(msg.content) };
    }
    return msg;
  });
}

