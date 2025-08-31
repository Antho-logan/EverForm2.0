#!/usr/bin/env bash
set -euo pipefail

# Config (override via env)
SCHEME="${SCHEME:-EverForm}"
CONFIGURATION="${CONFIGURATION:-Debug}"
DEVICE="${DEVICE:-iPhone 16 Pro}"
OS_VERSION="${OS_VERSION:-18.6}"

# Detect workspace or project
if find . -maxdepth 1 -name "*.xcworkspace" -type d | head -n1 | grep -q .; then
  ENTRY_FLAG="-workspace"
  ENTRY_FILE="$(find . -maxdepth 1 -name "*.xcworkspace" -type d | head -n1)"
else
  ENTRY_FLAG="-project"
  ENTRY_FILE="$(find . -maxdepth 1 -name "*.xcodeproj" -type d | head -n1)"
fi

echo "Using: $ENTRY_FLAG $ENTRY_FILE"

DERIVED="DerivedData"
echo "▶︎ Building $SCHEME ($CONFIGURATION) for Simulator…"
xcodebuild \
  "$ENTRY_FLAG" "$ENTRY_FILE" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "platform=iOS Simulator,name=$DEVICE,OS=$OS_VERSION" \
  -derivedDataPath "$DERIVED" \
  -quiet \
  build

# Find the .app product robustly
APP_PATH="$(/usr/bin/find "$DERIVED/Build/Products" -type d -name '*.app' -path '*-iphonesimulator/*' -print -quit)"
if [[ -z "${APP_PATH:-}" ]]; then
  echo "✖ Could not locate built .app in $DERIVED/Build/Products"
  exit 1
fi

echo "✅ Build succeeded."
echo "APP=$APP_PATH"
