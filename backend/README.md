# EverForm 2.0 Backend

Node.js + Express + TypeScript backend for the EverForm 2.0 iOS app.

## Setup

1.  Install dependencies:
    ```bash
    npm install
    ```

2.  Create a `.env` file based on your configuration (see `src/config/env.ts` for required variables).

3.  Run the server:
    ```bash
    npm run dev
    ```

4.  Verify health:
    ```bash
    curl http://localhost:4000/health
    ```
    Should return `{"status":"ok"}`.

## Coach & Scan verification

1.  **Start backend:**
    ```bash
    cd backend
    npm run dev
    ```

2.  **Health check:**
    ```bash
    curl http://localhost:4000/health
    ```

3.  **Coach test:**
    ```bash
    curl -X POST http://localhost:4000/api/v1/coach/message \
      -H "Content-Type: application/json" \
      -d '{"userId": "test-user", "message": "My back hurts"}'
    ```
    Should return: `{"reply": "..."}`

4.  **Scan mock test:**
    ```bash
    curl -X POST http://localhost:4000/api/v1/scan/analyze \
      -H "Content-Type: application/json" \
      -d '{"mode": "calories", "imageBase64": "dGVzdA=="}'
    ```
    Should return mock JSON with calories.
