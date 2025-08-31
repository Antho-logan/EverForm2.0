#!/usr/bin/env bash
set -euo pipefail

APP="${APP:-}"
if [[ -z "$APP" ]]; then
  while IFS= read -r line; do
    if [[ "$line" == APP=* ]]; then APP="${line#APP=}"; fi
  done
fi

if [[ -z "$APP" ]]; then
  echo "APP path not provided. Run tools/build.sh first or pass APP=/path/to.app"
  exit 1
fi

PLIST="$APP/Info.plist"
if [[ ! -f "$PLIST" ]]; then
  echo "Info.plist not found inside $APP"
  exit 1
fi

BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$PLIST" 2>/dev/null)"
if [[ -z "$BUNDLE_ID" ]]; then
  echo "Could not extract bundle ID from Info.plist"
  exit 1
fi

DEVICE="${DEVICE:-iPhone 16 Pro}"

echo "Booting Simulator ($DEVICE)..."
open -a Simulator >/dev/null 2>&1 || true

UDID="$(xcrun simctl list devices available | grep "$DEVICE" | grep -E '\([A-F0-9-]+\)' | head -1 | sed 's/.*(\([A-F0-9-]*\)).*/\1/')"
if [[ -z "$UDID" ]]; then
  UDID="$(xcrun simctl list devices available | grep iPhone | grep -E '\([A-F0-9-]+\)' | head -1 | sed 's/.*(\([A-F0-9-]*\)).*/\1/')"
fi
if [[ -z "$UDID" ]]; then
  echo "No available iOS simulators found."
  exit 1
fi

xcrun simctl boot "$UDID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$UDID" -b

echo "Installing $BUNDLE_ID..."
xcrun simctl uninstall "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl install "$UDID" "$APP"

echo "Launching..."
xcrun simctl launch "$UDID" "$BUNDLE_ID" || {
  echo "Launch returned non-zero; the app may already be running."
}

echo "Installed and launched: $BUNDLE_ID"
echo "UDID=$UDID"
exit 0
