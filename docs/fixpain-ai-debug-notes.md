# FixPain AI Debug Notes

1) Run backend
```
cd backend
npm run dev
```

2) Sanity check the endpoint
```
curl -i http://localhost:4000/api/v1/pain/assessment/complete \
  -H "Content-Type: application/json" \
  -d '{
    "bodyRegion": "shoulder",
    "side": "left",
    "painDuration": "acute",
    "painIntensity": 5,
    "painCharacter": ["sharp"],
    "aggravatingFactors": ["overhead press"],
    "relievingFactors": ["rest"],
    "activityContext": ["gym"],
    "redFlags": [],
    "functionalLimitations": ["hard to lift arm"],
    "notes": "test from curl",
    "photoUrl": null
  }'
```
Expect: HTTP 201 with JSON PainAiPlan. Backend logs: `[Pain] POST /assessment/complete { bodyRegion, side, painIntensity }`.

3) iOS base URL
- Simulator: `http://localhost:4000/api/v1`
- Physical device: replace `192.168.0.23` in `BackendConfig.baseURL` with your Mac’s LAN IP.

4) iOS flow
- Build & run EverForm scheme (simulator recommended).
- Complete FixPain wizard (e.g., region=wrist, intensity=5/10), tap Generate Plan.
- Expect: plan screen appears. If error, check:
  - Xcode console (FixPain view model logs backend/decoding errors)
  - Backend terminal for `[Pain]` logs and any errors.

### Decoding bug: createdAt format
- Backend returns ISO8601 with fractional seconds (e.g., 2025-12-08T16:28:02.647Z).
- Swift `JSONDecoder` `.iso8601` can’t parse fractional seconds by default.
- We treat `createdAt` as `String?` in `PainAiPlanDTO` to avoid decoding failures.

5) If UI still shows the red message:
- Verify device can reach the host/IP (curl from device via Safari or Proxyman).
- Confirm backend is running and port 4000 is open.

