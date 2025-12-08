# EverForm Backend v2.0

Node.js + Express + TypeScript backend for the EverForm iOS app.

## Quick Start

### 1. Create `.env`

```bash
# Required
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_JWT_SECRET=your-jwt-secret
DEEPSEEK_API_KEY=your-deepseek-key

# Dev mode (local development)
ALLOW_DEV_USER=true                                  # enables dev mode (bypasses JWT auth)
DEV_USER_ID=086d851d-1ae0-4d78-8603-d5707156d896    # REAL Supabase auth.users UUID

# Optional
SCAN_API_KEY=your-openrouter-key   # for real food scanning (uses mock if empty)
```

### 2. Run

From repo root:
```bash
npm run backend:dev
```

Or from backend folder:
```bash
cd backend
npm run dev
```

### 3. Verify

```bash
# Should return {"status":"ok","mode":"development",...}
curl http://localhost:4000/health

# Should return profile data (no auth needed in dev mode)
curl http://localhost:4000/api/v1/profile

# Should return nutrition data
curl http://localhost:4000/api/v1/nutrition/summary
```

---

## Auth Modes

### DEV MODE

**Enabled when:** `NODE_ENV=development` (from npm run dev) **OR** `ALLOW_DEV_USER=true`

**Behavior:**
- All `/api/v1/*` endpoints work without JWT
- Requests use `DEV_USER_ID` from `.env` as the user ID
- iOS app "just works" without auth configuration

**Important:** `DEV_USER_ID` must be a **real UUID** from your `auth.users` table in Supabase. Using a fake string will cause UUID validation errors on tables with foreign key constraints (like `training_profiles`).

### PROD MODE

**Enabled when:** Neither of the above conditions

**Behavior:**
- All `/api/v1/*` endpoints require `Authorization: Bearer <jwt>`
- Missing/invalid token returns 401
- No hidden fallbacks

---

## API Endpoints

### Public (no auth)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Server health check |

### AI (auth + rate limited)

| Method | Path | Description | Rate Limit |
|--------|------|-------------|------------|
| POST | `/api/coach/chat` | AI coach chat | 20/min |
| POST | `/api/scan/food` | Food image analysis | 10/min |
| GET | `/api/scan/test` | Scan API health | - |

### User Data (`/api/v1/*`)

All endpoints use `req.user.id` for user scoping.

**Profile:**
- `GET /api/v1/profile` - Get profile + onboarding answers
- `PUT /api/v1/profile` - Update profile

**Dashboard:**
- `GET /api/v1/dashboard/today` - Today's aggregated data
- `GET /api/v1/dashboard/week` - Last 7 days

**Training:**
- `GET /api/v1/training/sessions` - Planned sessions
- `POST /api/v1/training/log` - Log completed workout
- `GET /api/v1/training/templates` - Workout templates

**Nutrition:**
- `GET /api/v1/nutrition/summary` - Daily totals + logs
- `POST /api/v1/nutrition/log` - Log food
- `GET /api/v1/nutrition/targets` - Macro targets
- `POST /api/v1/nutrition/targets` - Set targets

**Recovery & Sleep:**
- `POST /api/v1/recovery/log` - Log recovery activities
- `POST /api/v1/sleep/log` - Log sleep
- `GET /api/v1/recovery/feedback` - AI feedback

**Coach:**
- `GET /api/v1/coach/daily` - Daily summary
- `GET /api/v1/coach/weekly` - Weekly report
- `GET /api/v1/coach/messages` - Message history
- `POST /api/v1/coach/message` - Send message

**Goals:**
- `GET /api/v1/goals` - Get goals
- `POST /api/v1/goals` - Update goals

---

## Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start with hot reload (dev mode) |
| `npm run build` | Compile TypeScript |
| `npm start` | Run compiled (prod mode) |
| `npm run lint` | Type check |
| `npm run job:daily` | Run daily summary job |
| `npm run job:weekly` | Run weekly report job |

---

## Troubleshooting

### Getting 401 errors in dev?

Check your startup output. You should see:

```
║  🔓 Auth Mode:   DEV (no JWT required)                     ║
║  👤 Dev User:    086d851d-1ae0-4d78-8603-d5707156d896      ║
```

(Your UUID will be different - it should match your `DEV_USER_ID` env var)

If you see `PRODUCTION (JWT required)` instead:
1. Make sure `.env` has `ALLOW_DEV_USER=true`, OR
2. Make sure you're running `npm run dev` (which sets `NODE_ENV=development`)

### Health returns `mode: "production"`?

Either:
- `NODE_ENV` is not `development`, AND
- `ALLOW_DEV_USER` is not `true`

Fix: Add `ALLOW_DEV_USER=true` to `.env` and restart.

### Food scanning returns mock data?

Set `SCAN_API_KEY` in `.env` with your OpenRouter API key.

---

## Security

- **Service role client** (`supabase`): Bypasses RLS. Used for admin/jobs only.
- **User client** (`supabaseUser`): Respects RLS. Used for user-facing routes.
- **Rate limiting**: AI endpoints limited per user/IP.
- **No fake 201s**: Write failures return 500, not fake success.

In production:
- Remove `ALLOW_DEV_USER` from environment
- All requests require valid JWT from Supabase Auth
- Service role key is never exposed to clients

---

## RAG Setup (Knowledge Base)

The AI coach can use your knowledge base (`documents` + `chunks` tables) to provide smarter, evidence-based answers.

### 1. Add OpenAI API Key to `.env`

```bash
# Add to your backend/.env
OPENAI_API_KEY=sk-your-openai-api-key
OPENAI_BASE_URL=https://api.openai.com/v1   # optional, this is the default
EMBEDDING_MODEL=text-embedding-3-small       # optional, this is the default
```

### 2. Run the SQL Migration in Supabase

Open **Supabase Dashboard → SQL Editor** and paste:

```sql
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

grant execute on function match_documents to authenticated, service_role;
```

Click **Run**. This is safe to run multiple times (idempotent).

### 3. Test RAG

```bash
# Restart backend to pick up new env vars
npm run backend:dev

# Test with a knowledge question
curl -X POST http://localhost:4000/api/coach/chat \
  -H "Content-Type: application/json" \
  -d '{"prompt": "How can I improve my deep sleep and recovery after heavy leg day sessions?"}'
```

You should see `[coach/chat] RAG: Found relevant knowledge chunks` in the backend logs if it's working.

### RAG Graceful Degradation

| Condition | Behavior |
|-----------|----------|
| `OPENAI_API_KEY` missing | RAG disabled, chat works normally |
| `match_documents` RPC missing | Falls back to client-side search (slower) |
| No matching chunks found | Chat responds without knowledge context |
| OpenAI API error | RAG skipped, chat continues |

The app **always works** even if RAG is not configured. You just get general coaching instead of knowledge-backed answers
