# EverForm

This workspace powers the EverForm SwiftUI app. Please avoid editing or deleting the Sweetpad configuration files (`sweetpad.json`, build logs, etc.) — they keep our remote build pipeline connected. If Sweetpad breaks, report it instead of tweaking the connection settings.

## Sweetpad Guard

Run `scripts/sweetpad_guard.sh` before pushing to guarantee the Sweetpad connection files still match the expected hash. If you intentionally update `sweetpad.json`, the guard script will automatically update the lock file. This ensures the connection stays intact.

## Quick start

- Backend: `cd backend && npm install && npm run dev` (health at `http://localhost:4000/health`).
- iOS app: open the workspace in Xcode, run on Simulator with the backend running at `http://localhost:4000` (dev auth fallback is auto-enabled).

## Build notes

- Resolved duplicate `OnboardingFlow.stringsdata` by compiling only `tip tracker/Features/Onboarding/OnboardingFlow.swift` (legacy `Features/Onboarding/OnboardingFlow.swift` is excluded from the target).
