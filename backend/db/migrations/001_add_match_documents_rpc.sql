-- ============================================================================
-- Migration: Add match_documents RPC for RAG Vector Similarity Search
-- ============================================================================
-- This function enables efficient vector similarity search for the RAG system.
-- It searches the chunks table for content similar to the query embedding.
--
-- Run this in your Supabase SQL Editor if you want optimal performance.
-- The backend will fall back to client-side computation if this RPC is missing.
-- ============================================================================

-- Ensure pgvector extension is enabled
create extension if not exists vector;

-- Create the match_documents function for semantic search
-- This assumes your table structure is:
--   documents(id, title, topic, ...)
--   chunks(id, document_id, content, embedding)
--
-- Adjust column names if your Supabase template uses different names.

create or replace function match_documents(
  query_embedding vector(1536),
  match_threshold float default 0.70,
  match_count int default 5,
  filter_topic text default null
)
returns table (
  chunk_id text,
  document_id uuid,
  title text,
  topic text,
  content text,
  similarity float
)
language plpgsql
as $$
begin
  return query
  select
    c.id::text as chunk_id,
    c.document_id,
    d.title,
    d.topic,
    c.content,
    1 - (c.embedding <=> query_embedding) as similarity
  from chunks c
  join documents d on c.document_id = d.id
  where 
    1 - (c.embedding <=> query_embedding) >= match_threshold
    and (filter_topic is null or d.topic = filter_topic)
  order by c.embedding <=> query_embedding
  limit match_count;
end;
$$;

-- Grant execute permission to authenticated and service_role
grant execute on function match_documents to authenticated;
grant execute on function match_documents to service_role;

-- Create index for faster vector similarity search (optional but recommended)
-- Uncomment if you have many chunks (1000+)
-- create index if not exists idx_chunks_embedding on chunks 
--   using ivfflat (embedding vector_cosine_ops) 
--   with (lists = 100);

-- ============================================================================
-- Alternative: If your tables are named knowledge_documents/knowledge_embeddings
-- (from schema.sql), use this version instead:
-- ============================================================================

/*
create or replace function match_knowledge_documents(
  query_embedding vector(1536),
  match_threshold float default 0.70,
  match_count int default 5,
  filter_category text default null
)
returns table (
  chunk_id text,
  document_id uuid,
  title text,
  topic text,
  content text,
  similarity float
)
language plpgsql
as $$
begin
  return query
  select
    ke.id::text as chunk_id,
    ke.document_id,
    kd.title,
    kd.category as topic,
    ke.chunk_text as content,
    1 - (ke.embedding <=> query_embedding) as similarity
  from knowledge_embeddings ke
  join knowledge_documents kd on ke.document_id = kd.id
  where 
    1 - (ke.embedding <=> query_embedding) >= match_threshold
    and (filter_category is null or kd.category = filter_category)
  order by ke.embedding <=> query_embedding
  limit match_count;
end;
$$;
*/


