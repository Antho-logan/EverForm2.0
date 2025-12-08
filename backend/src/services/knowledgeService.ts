/**
 * Knowledge Service - RAG Layer for EverForm AI Coach
 * 
 * Provides vector similarity search over the internal knowledge base
 * (PDFs → documents → chunks with embeddings).
 * 
 * ASSUMPTIONS about Supabase tables (from Supabase template):
 * - public.documents(id uuid, title text, topic text?, metadata jsonb?)
 * - public.chunks(id bigint/uuid, document_id uuid FK, content text, embedding vector)
 * 
 * If your table structure differs, adjust the column names in the queries below.
 * The service gracefully degrades if embeddings are not configured.
 */

import axios from 'axios';
import { supabase } from '../config/supabaseClient';
import { env } from '../config/env';

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

export interface KnowledgeMatch {
  chunkId: string;
  documentId: string;
  title: string;
  topic: string | null;
  content: string;
  score: number; // 0–1 similarity (higher = better match)
}

export interface SearchOptions {
  topic?: string;      // Filter by document topic/category
  limit?: number;      // Max results (default: 5)
  minScore?: number;   // Minimum similarity threshold (default: 0.70)
}

// ─────────────────────────────────────────────────────────────────────────────
// Configuration & State
// ─────────────────────────────────────────────────────────────────────────────

const EMBEDDING_DIMENSIONS = 1536; // text-embedding-3-small default

// Singleton check for embeddings availability
let embeddingsEnabled: boolean | null = null;

function checkEmbeddingsEnabled(): boolean {
  if (embeddingsEnabled !== null) return embeddingsEnabled;
  
  if (!env.OPENAI_API_KEY) {
    console.warn('[knowledge] ⚠ Embeddings disabled: OPENAI_API_KEY missing');
    embeddingsEnabled = false;
  } else {
    embeddingsEnabled = true;
    console.log('[knowledge] ✓ Embeddings enabled');
  }
  return embeddingsEnabled;
}

// ─────────────────────────────────────────────────────────────────────────────
// Embedding Generation
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Generates an embedding vector for the given text using OpenAI's API.
 * 
 * @param text - The text to embed
 * @returns Embedding vector as number array, or null if embeddings are disabled/failed
 */
export async function embedQuery(text: string): Promise<number[] | null> {
  if (!checkEmbeddingsEnabled()) {
    return null;
  }

  const baseUrl = env.OPENAI_BASE_URL || 'https://api.openai.com/v1';
  const model = env.EMBEDDING_MODEL || 'text-embedding-3-small';

  try {
    const response = await axios.post(
      `${baseUrl}/embeddings`,
      {
        input: text.slice(0, 8000), // Truncate to avoid token limits
        model,
      },
      {
        headers: {
          Authorization: `Bearer ${env.OPENAI_API_KEY}`,
          'Content-Type': 'application/json',
        },
        timeout: 10000,
      }
    );

    const embedding = response.data?.data?.[0]?.embedding;
    if (Array.isArray(embedding) && embedding.length > 0) {
      return embedding;
    }

    console.warn('[knowledge] Unexpected embedding response format');
    return null;
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    console.error('[knowledge] Embedding API error:', message);
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vector Similarity Search
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Searches the knowledge base for chunks similar to the query.
 * 
 * Uses pgvector similarity search via Supabase RPC (match_documents function)
 * or falls back to a raw query if the RPC doesn't exist.
 * 
 * @param query - User's question or search text
 * @param opts - Search options (topic filter, limit, minScore)
 * @returns Array of matching chunks with metadata, sorted by relevance
 */
export async function searchKnowledge(
  query: string,
  opts: SearchOptions = {}
): Promise<KnowledgeMatch[]> {
  const { topic, limit = 5, minScore = 0.70 } = opts;

  // Check if embeddings are available
  if (!checkEmbeddingsEnabled()) {
    return [];
  }

  // Generate query embedding
  const queryEmbedding = await embedQuery(query);
  if (!queryEmbedding) {
    console.warn('[knowledge] Failed to generate query embedding');
    return [];
  }

  try {
    // Try using Supabase RPC function first (common pattern from templates)
    // The function should be: match_documents(query_embedding, match_threshold, match_count)
    const { data: rpcData, error: rpcError } = await supabase.rpc('match_documents', {
      query_embedding: queryEmbedding,
      match_threshold: minScore,
      match_count: limit,
      filter_topic: topic || null,
    });

    if (!rpcError && rpcData && Array.isArray(rpcData) && rpcData.length > 0) {
      return mapRpcResults(rpcData);
    }

    // RPC failed or doesn't exist - try direct query approach
    if (rpcError) {
      console.log('[knowledge] RPC not available, trying direct query. Error:', rpcError.message);
    }

    // Fallback: Direct query using raw SQL via postgrest
    // This uses the <=> operator for cosine distance
    return await searchKnowledgeDirect(queryEmbedding, { topic, limit, minScore });
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    console.error('[knowledge] Search error:', message);
    return [];
  }
}

/**
 * Direct search without RPC - uses raw Supabase query.
 * This is the fallback when match_documents RPC is not available.
 */
async function searchKnowledgeDirect(
  queryEmbedding: number[],
  opts: { topic?: string; limit: number; minScore: number }
): Promise<KnowledgeMatch[]> {
  const { topic, limit, minScore } = opts;

  // Convert embedding to pgvector format: '[0.1,0.2,...]'
  const embeddingStr = `[${queryEmbedding.join(',')}]`;

  // Build the raw SQL query
  // Using cosine distance: 1 - (embedding <=> query) gives similarity
  let sql = `
    SELECT 
      c.id as chunk_id,
      c.document_id,
      d.title,
      d.topic,
      c.content,
      1 - (c.embedding <=> '${embeddingStr}'::vector) as similarity
    FROM chunks c
    JOIN documents d ON c.document_id = d.id
    WHERE 1 - (c.embedding <=> '${embeddingStr}'::vector) >= ${minScore}
  `;

  if (topic) {
    sql += ` AND d.topic = '${topic.replace(/'/g, "''")}'`;
  }

  sql += ` ORDER BY similarity DESC LIMIT ${limit}`;

  // Execute via RPC (requires a generic SQL executor function) or use postgrest
  // Since we can't run raw SQL directly, we'll try a different approach:
  // Query chunks ordered by a computed column isn't directly supported,
  // so we need to rely on the RPC or a view.

  // Alternative: Query all chunks from relevant documents and compute similarity client-side
  // This is less efficient but works without custom SQL functions
  try {
    let documentsQuery = supabase.from('documents').select('id, title, topic');
    if (topic) {
      documentsQuery = documentsQuery.eq('topic', topic);
    }
    const { data: docs, error: docsError } = await documentsQuery;

    if (docsError || !docs || docs.length === 0) {
      console.warn('[knowledge] No documents found or error:', docsError?.message);
      return [];
    }

    const docIds = docs.map((d) => d.id);
    const docMap = new Map(docs.map((d) => [d.id, { title: d.title, topic: d.topic }]));

    // Fetch chunks for these documents
    const { data: chunks, error: chunksError } = await supabase
      .from('chunks')
      .select('id, document_id, content, embedding')
      .in('document_id', docIds);

    if (chunksError || !chunks || chunks.length === 0) {
      console.warn('[knowledge] No chunks found or error:', chunksError?.message);
      return [];
    }

    // Compute cosine similarity client-side
    const results: KnowledgeMatch[] = chunks
      .map((chunk) => {
        const chunkEmbedding = parseEmbedding(chunk.embedding);
        if (!chunkEmbedding) return null;

        const similarity = cosineSimilarity(queryEmbedding, chunkEmbedding);
        const doc = docMap.get(chunk.document_id);

        return {
          chunkId: String(chunk.id),
          documentId: chunk.document_id,
          title: doc?.title ?? 'Unknown',
          topic: doc?.topic ?? null,
          content: chunk.content,
          score: similarity,
        };
      })
      .filter((r): r is KnowledgeMatch => r !== null && r.score >= minScore)
      .sort((a, b) => b.score - a.score)
      .slice(0, limit);

    return results;
  } catch (err) {
    console.error('[knowledge] Direct search error:', err);
    return [];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Utility Functions
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Maps RPC results to KnowledgeMatch format.
 * Adjust field names based on your match_documents function output.
 */
function mapRpcResults(data: any[]): KnowledgeMatch[] {
  return data.map((row) => ({
    chunkId: String(row.chunk_id ?? row.id ?? ''),
    documentId: row.document_id ?? '',
    title: row.title ?? row.document_title ?? 'Unknown',
    topic: row.topic ?? row.document_topic ?? null,
    content: row.content ?? row.chunk_content ?? '',
    score: row.similarity ?? row.score ?? 0,
  }));
}

/**
 * Parses an embedding from Supabase (could be string, array, or null).
 */
function parseEmbedding(embedding: unknown): number[] | null {
  if (!embedding) return null;

  if (Array.isArray(embedding)) {
    return embedding as number[];
  }

  if (typeof embedding === 'string') {
    try {
      // Handle pgvector string format: '[0.1,0.2,...]'
      const cleaned = embedding.replace(/^\[|\]$/g, '');
      return cleaned.split(',').map(Number);
    } catch {
      return null;
    }
  }

  return null;
}

/**
 * Computes cosine similarity between two vectors.
 * Returns value between 0 (orthogonal) and 1 (identical).
 */
function cosineSimilarity(a: number[], b: number[]): number {
  if (a.length !== b.length) return 0;

  let dotProduct = 0;
  let normA = 0;
  let normB = 0;

  for (let i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }

  const denominator = Math.sqrt(normA) * Math.sqrt(normB);
  return denominator === 0 ? 0 : dotProduct / denominator;
}

// ─────────────────────────────────────────────────────────────────────────────
// RAG Context Builder
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Determines if a message is likely a knowledge-seeking question.
 * Uses simple heuristics - can be replaced with LLM classifier later.
 */
export function isKnowledgeQuestion(message: string): boolean {
  const lowerMessage = message.toLowerCase();
  const length = message.length;

  // Short messages are usually greetings or simple commands
  if (length < 15) return false;

  // Question indicators
  const questionWords = ['how', 'why', 'what', 'when', 'where', 'which', 'should', 'can', 'does', 'is', 'are'];
  const hasQuestionWord = questionWords.some((w) => lowerMessage.startsWith(w) || lowerMessage.includes(` ${w} `));

  // Domain keywords that suggest knowledge lookup
  const domainKeywords = [
    'protocol', 'plan', 'routine', 'schedule', 'program',
    'sleep', 'recovery', 'nutrition', 'diet', 'eating', 'fasting', 'macros', 'protein', 'calories',
    'training', 'workout', 'exercise', 'lift', 'strength', 'cardio', 'conditioning',
    'stress', 'anxiety', 'mental', 'mindset', 'focus', 'meditation', 'breathwork',
    'hormone', 'testosterone', 'cortisol', 'insulin', 'thyroid',
    'mobility', 'flexibility', 'stretch', 'warmup', 'cooldown',
    'muscle', 'hypertrophy', 'strength', 'endurance', 'performance',
    'longevity', 'aging', 'biohacking', 'optimization', 'supplement',
    'circadian', 'deep sleep', 'rem', 'hrv', 'heart rate',
    'improve', 'increase', 'decrease', 'optimize', 'enhance', 'boost',
    'best', 'ideal', 'optimal', 'recommended', 'research', 'evidence',
  ];
  const hasDomainKeyword = domainKeywords.some((k) => lowerMessage.includes(k));

  // Combine heuristics
  return hasQuestionWord || hasDomainKeyword || length > 50;
}

/**
 * Formats knowledge matches into a context string for LLM prompts.
 * @internal Use buildKnowledgeContext() for the high-level API.
 */
function formatMatchesAsContext(matches: KnowledgeMatch[]): string | null {
  if (!matches || matches.length === 0) return null;

  const contextParts = matches.map((m, idx) => {
    const topicLabel = m.topic ? ` (${m.topic})` : '';
    // Truncate very long chunks to avoid token bloat
    const content = m.content.length > 1500 ? m.content.slice(0, 1500) + '...' : m.content;
    return `[${idx + 1}] **${m.title}**${topicLabel}\n${content}`;
  });

  return `Here are relevant excerpts from the EverForm knowledge base:\n\n${contextParts.join('\n\n---\n\n')}`;
}

// ─────────────────────────────────────────────────────────────────────────────
// High-Level RAG API
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Builds a knowledge context string from the knowledge base for a given question.
 * This is the main entry point for RAG lookups.
 * 
 * @param question - User's question to search for
 * @param topic - Optional topic filter (e.g., 'sleep', 'nutrition')
 * @returns Formatted context string, or null if no relevant knowledge found
 */
export async function buildKnowledgeContext(
  question: string,
  topic?: string
): Promise<string | null> {
  try {
    // Search knowledge base
    const matches = await searchKnowledge(question, {
      topic,
      limit: 5,
      minScore: 0.70,
    });

    if (matches.length === 0) {
      return null;
    }

    // Format top matches as context
    return formatMatchesAsContext(matches);
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    console.error('[knowledge] buildKnowledgeContext error:', message);
    return null;
  }
}

/**
 * Main entry point for RAG-enhanced responses.
 * Checks if question is knowledge-eligible, searches, and returns context.
 * 
 * @param userMessage - The user's message/question
 * @returns Knowledge context string, or null if no relevant knowledge found
 */
export async function getKnowledgeContext(userMessage: string): Promise<string | null> {
  // Check if this is a knowledge question
  if (!isKnowledgeQuestion(userMessage)) {
    return null;
  }

  return buildKnowledgeContext(userMessage);
}

