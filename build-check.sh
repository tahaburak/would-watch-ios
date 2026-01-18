#!/bin/bash

# Build verification script for would_watch iOS app
# This script checks if the project compiles successfully

set -e  # Exit on error

echo "🔍 Checking iOS project build..."
echo ""

# Navigate to iOS directory
cd "$(dirname "$0")"

# Find the Xcode project
XCODE_PROJECT="would_watch.xcodeproj"
if [ ! -d "$XCODE_PROJECT" ]; then
    echo "❌ Error: $XCODE_PROJECT not found"
    exit 1
fi

echo "📦 Project found: $XCODE_PROJECT"
echo ""

# Get the scheme name (usually same as project name without extension)
SCHEME="would_watch"

# Check if we're on macOS (required for iOS builds)
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  Warning: iOS builds require macOS. Skipping build check."
    echo "✅ Project structure looks valid"
    exit 0
fi

# Try to build the project
echo "🔨 Building project..."
echo ""

# Use xcodebuild to build (without running)
xcodebuild \
    -project "$XCODE_PROJECT" \
    -scheme "$SCHEME" \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    clean build \
    2>&1 | tee build.log

# Check build result
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "✅ Build successful! Project compiles without errors."
    rm -f build.log
    exit 0
else
    echo ""
    echo "❌ Build failed! Check build.log for details."
    echo "📄 Full build log saved to: build.log"
    exit 1
fi
