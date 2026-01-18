#!/bin/bash

# iOS Test Runner Script
# Runs tests on iOS Simulator

set -e

PROJECT_PATH="would_watch.xcodeproj"
SCHEME="would_watch"
SIMULATOR="iPhone 15"
OS_VERSION="latest"

echo "🧪 Running iOS Tests..."
echo "Project: $PROJECT_PATH"
echo "Scheme: $SCHEME"
echo "Simulator: $SIMULATOR"
echo ""

# Run Unit Tests
echo "▶️  Running Unit Tests..."
xcodebuild test \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=$SIMULATOR,OS=$OS_VERSION" \
  -only-testing:would_watchTests \
  -quiet

echo "✅ Unit Tests Passed!"
echo ""

# Run UI Tests
echo "▶️  Running UI Tests..."
xcodebuild test \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=$SIMULATOR,OS=$OS_VERSION" \
  -only-testing:would_watchUITests \
  -quiet

echo "✅ UI Tests Passed!"
echo ""
echo "🎉 All tests passed successfully!"
