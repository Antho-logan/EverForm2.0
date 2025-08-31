#!/usr/bin/env bash
set -euo pipefail

DEST="${1:-platform=iOS Simulator,name=iPhone 16 Pro}"
DEVICE_NAME=$(echo "$DEST" | sed 's/.*name=\([^,]*\).*/\1/')
BUNDLE_ID="com.Webproducta.EverForm"
APP_PATH=".derived/Build/Products/Debug-iphonesimulator/EverForm.app"

echo "📱 Running EverForm on: $DEVICE_NAME"

# Boot simulator if needed
DEVICE_ID=$(xcrun simctl list devices | grep "$DEVICE_NAME" | grep -E "\(Shutdown\)|\(Booted\)" | head -1 | sed 's/.*(\([^)]*\)).*/\1/')

if [ -z "$DEVICE_ID" ]; then
    echo "❌ Device '$DEVICE_NAME' not found"
    exit 1
fi

echo "🚀 Booting simulator: $DEVICE_ID"
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true

# Wait for boot
sleep 3

# Install and launch
if [ -d "$APP_PATH" ]; then
    echo "📦 Installing app..."
    xcrun simctl install "$DEVICE_ID" "$APP_PATH"
    
    echo "🎯 Launching app..."
    xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
    
    echo "✅ App launched successfully!"
else
    echo "❌ App not found at: $APP_PATH"
    echo "💡 Run 'make build' first"
    exit 1
fi

