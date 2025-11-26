# EverForm

This workspace powers the EverForm SwiftUI app. Please avoid editing or deleting the Sweetpad configuration files (`sweetpad.json`, build logs, etc.) — they keep our remote build pipeline connected. If Sweetpad breaks, report it instead of tweaking the connection settings.

## Sweetpad Guard

Run `scripts/sweetpad_guard.sh` before pushing to guarantee the Sweetpad connection files still match the expected hash. If you intentionally update `sweetpad.json`, the guard script will automatically update the lock file. This ensures the connection stays intact.
