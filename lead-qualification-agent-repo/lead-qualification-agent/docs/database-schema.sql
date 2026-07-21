-- Supabase (Postgres + pgvector) schema for the lead qualification knowledge base
-- Embedding dimension is 3072 to match Google Gemini's `models/gemini-embedding-001`

drop function if exists match_documents;
drop table if exists documents;

create extension if not exists vector;

create table documents (
  id uuid primary key default gen_random_uuid(),
  content text,
  metadata jsonb,
  embedding vector(3072)
);

-- Function used by n8n's Supabase Vector Store node (Retrieve mode) to perform
-- similarity search over the embedded document chunks.
create function match_documents (
  query_embedding vector(3072),
  match_count int default null,
  filter jsonb default '{}'
) returns table (id uuid, content text, metadata jsonb, similarity float)
language plpgsql as $$
#variable_conflict use_column
begin
  return query
  select id, content, metadata,
    1 - (documents.embedding <=> query_embedding) as similarity
  from documents
  where metadata @> filter
  order by documents.embedding <=> query_embedding
  limit match_count;
end;
$$;

-- Notes:
-- * Workflow 1 (data-ingestion) INSERTS rows here (Operation Mode: "Insert Documents")
-- * Workflow 2 (chatbot) RETRIEVES rows here (Operation Mode: "Retrieve Documents (As Tool for AI Agent)")
-- * Both the ingestion and retrieval Embeddings sub-nodes must use the SAME embedding
--   model (models/gemini-embedding-001) with the same credential, or similarity search
--   will silently return wrong/irrelevant results.
