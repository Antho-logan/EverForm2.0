#!/usr/bin/env bash
set -euo pipefail

PROJ="EverForm.xcodeproj"
SCHEME="EverForm"
DEST="${1:-platform=iOS Simulator,name=iPhone 16 Pro}"

echo "🔨 Building EverForm for iOS Simulator..."
echo "📱 Destination: $DEST"

# Build with simulator-friendly settings
xcodebuild -project "$PROJ" -scheme "$SCHEME" -configuration Debug \
  -destination "$DEST" -derivedDataPath .derived \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  DEVELOPMENT_TEAM="" \
  clean build 2>&1 | grep -v "Using the first of multiple matching destinations" || {
    echo "❌ Build failed. Checking logs..."
    tail -n 200 ~/Library/Logs/DiagnosticReports/* 2>/dev/null || true
    exit 65
  }

echo "✅ Build succeeded!"
