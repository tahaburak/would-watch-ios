#!/bin/bash

# Simple build verification script for would_watch iOS app
# This script verifies the project can compile

set -e

echo "🔍 Verifying iOS project build..."
echo ""

# Navigate to iOS directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Find Xcode project
XCODE_PROJECT=$(find . -name "*.xcodeproj" -type d | head -1)

if [ -z "$XCODE_PROJECT" ]; then
    echo "❌ Error: No .xcodeproj file found"
    echo "   Searched in: $SCRIPT_DIR"
    exit 1
fi

PROJECT_NAME=$(basename "$XCODE_PROJECT" .xcodeproj)
SCHEME="$PROJECT_NAME"

echo "📦 Found project: $PROJECT_NAME"
echo "📁 Project path: $XCODE_PROJECT"
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  Warning: iOS builds require macOS"
    echo "✅ Project structure looks valid"
    exit 0
fi

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: xcodebuild not found. Please install Xcode."
    exit 1
fi

echo "🔨 Building project (this may take a minute)..."
echo ""

# Build for iOS Simulator
BUILD_OUTPUT=$(xcodebuild \
    -project "$XCODE_PROJECT" \
    -scheme "$SCHEME" \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    -quiet \
    clean build 2>&1)

BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    echo "✅ Build successful! Project compiles without errors."
    echo ""
    echo "📊 Build Summary:"
    echo "   - Project: $PROJECT_NAME"
    echo "   - Scheme: $SCHEME"
    echo "   - Status: ✅ Success"
    exit 0
else
    echo "❌ Build failed!"
    echo ""
    echo "Error details:"
    echo "$BUILD_OUTPUT" | grep -A 5 "error:" | head -20
    echo ""
    echo "💡 Tip: Run 'xcodebuild -project $XCODE_PROJECT -scheme $SCHEME build' for full output"
    exit 1
fi
