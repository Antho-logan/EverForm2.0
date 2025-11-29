# EverForm 2.0 Backend

Node.js + Express + TypeScript backend for the EverForm 2.0 iOS app.

## Environment Variables

Create a `.env` file in this directory with the following variables:

```bash
# Server
PORT=4000

# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_JWT_SECRET=your-jwt-secret

# DeepSeek LLM API (for coach chat)
DEEPSEEK_API_KEY=your-deepseek-api-key

# OpenRouter Vision API (for food scanning)
SCAN_API_URL=https://openrouter.ai/api/v1/chat/completions
SCAN_API_KEY=your-openrouter-api-key
```

**Important:** Never commit `.env` to version control. It's already in `.gitignore`.

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Create your `.env` file with the variables above.

3. Run the development server:
   ```bash
   npm run dev
   ```

4. Build for production:
   ```bash
   npm run build
   npm start
   ```

## API Endpoints

### Public Endpoints (No Auth Required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/debug/user-test` | Connectivity test |
| POST | `/api/coach/chat` | Coach chat (LLM) |
| POST | `/api/scan/food` | Food scan (mock) |

### Authenticated Endpoints (`/api/v1/*`)

All routes under `/api/v1` require a valid Supabase JWT in the `Authorization` header.

In development mode (non-production), a fallback dev user is used when no auth is provided.

## Testing the API

### Health Check

```bash
curl http://localhost:4000/health
```

Response:
```json
{"status":"ok","timestamp":"2025-11-29T12:00:00.000Z"}
```

### Debug Connectivity

```bash
curl http://localhost:4000/debug/user-test
```

Response:
```json
{"ok":true,"message":"Backend is reachable"}
```

### Coach Chat

```bash
curl -X POST http://localhost:4000/api/coach/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "How can I improve my sleep?"}
    ]
  }'
```

Response:
```json
{
  "reply": "Focus on consistent sleep/wake times, limit blue light 2 hours before bed, and keep your room cool (65-68°F). These three changes alone can dramatically improve sleep quality.",
  "usage": {"prompt_tokens": 50, "completion_tokens": 45, "total_tokens": 95}
}
```

### Food Scan (Mock)

```bash
curl -X POST http://localhost:4000/api/scan/food \
  -H "Content-Type: application/json" \
  -d '{
    "mode": "calories"
  }'
```

Response:
```json
{
  "item": "Mixed meal",
  "calories": 550,
  "protein": 32,
  "carbs": 45,
  "fat": 22,
  "confidence": 0.85
}
```

Supported modes: `calories`, `ingredients`, `plate`

## iOS App Configuration

The iOS app should connect to:
- **Simulator:** `http://localhost:4000`
- **Device on same network:** `http://<your-mac-ip>:4000`

CORS is configured to allow requests from any origin in development.

## Project Structure

```
backend/
├── src/
│   ├── config/
│   │   ├── env.ts           # Environment variable loading/validation
│   │   └── supabaseClient.ts # Supabase client singleton
│   ├── middleware/
│   │   └── auth.ts          # JWT auth middleware
│   ├── routes/
│   │   ├── index.ts         # Route aggregator for /api/v1
│   │   ├── publicCoach.ts   # /api/coach/* (no auth)
│   │   ├── publicScan.ts    # /api/scan/* (no auth)
│   │   ├── coach.ts         # /api/v1/coach/* (auth required)
│   │   ├── scan.ts          # /api/v1/scan/* (auth required)
│   │   └── ...              # Other feature routes
│   ├── services/
│   │   ├── aiService.ts     # DeepSeek LLM integration
│   │   └── scanService.ts   # Vision API for food scanning
│   ├── types/
│   │   └── index.ts         # TypeScript interfaces
│   └── server.ts            # Express app entry point
├── dist/                    # Compiled JavaScript (gitignored)
├── package.json
├── tsconfig.json
└── README.md
```

## Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start development server with hot reload |
| `npm run build` | Compile TypeScript to JavaScript |
| `npm start` | Run compiled JavaScript (production) |
