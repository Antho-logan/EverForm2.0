IOS_DEST=platform=iOS Simulator,name=iPhone 16 Pro

.PHONY: build run clean

build:
	@echo "🔨 Building EverForm..."
	@./scripts/ios-build.sh "$(IOS_DEST)"

run: build
	@echo "🚀 Running EverForm..."
	@./scripts/ios-run-sim.sh "$(IOS_DEST)"

clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf .derived
	@xcodebuild -project EverForm.xcodeproj -scheme EverForm clean

help:
	@echo "Available commands:"
	@echo "  make build  - Build the iOS app for simulator"
	@echo "  make run    - Build and run the app in simulator"
	@echo "  make clean  - Clean build artifacts"

