# EverForm

SwiftUI fitness & biohacking app with Node.js backend.

## Quick Start (Local Dev)

### 1. Configure Environment

Create `backend/.env`:

```bash
# Required - get these from Supabase dashboard
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_JWT_SECRET=your-jwt-secret
DEEPSEEK_API_KEY=your-deepseek-key

# Optional - enables dev mode without needing NODE_ENV
ALLOW_DEV_USER=true
```

### 2. Start Backend

```bash
npm run backend:dev
```

You should see:

```
╔═══════════════════════════════════════════════════════════╗
║           EverForm Backend v2.0.0                         ║
╠═══════════════════════════════════════════════════════════╣
║  🌐 Server:      http://localhost:4000                     ║
║  📦 NODE_ENV:    development                               ║
║  🔓 Auth Mode:   DEV (no JWT required)                     ║
║  👤 Dev User:    dev-user-0001                             ║
...
✅ iOS app can call /api/v1/* without auth token
```

### 3. Verify It Works

```bash
# Health check
curl http://localhost:4000/health
# → {"status":"ok","mode":"development",...}

# Profile (works without auth in dev!)
curl http://localhost:4000/api/v1/profile
# → {"profile":{...},"status":"ok" or "fallback"}

# Nutrition summary
curl http://localhost:4000/api/v1/nutrition/summary
# → {"date":"...","totals":{...},"status":"ok"}
```

### 4. Run iOS App

Open in Xcode, run on Simulator. The app connects to `localhost:4000` and works without auth configuration.

---

## Auth Modes

| Mode | When | Behavior |
|------|------|----------|
| **DEV** | `NODE_ENV=development` OR `ALLOW_DEV_USER=true` | No JWT required. Uses `dev-user-0001`. |
| **PROD** | Neither condition | Requires valid JWT. Returns 401 without token. |

---

## Sweetpad Guard

Run `scripts/sweetpad_guard.sh` before pushing to keep Sweetpad config intact.

---

## Documentation

- Backend details: `backend/README.md`
- API endpoints: `backend/README.md`
