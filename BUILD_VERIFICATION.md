# Build Verification Guide

This guide explains how to verify that the iOS project compiles successfully.

## Quick Verification

### Option 1: Using the Build Script (Recommended)

Run the verification script from the `ios` directory:

```bash
cd ios
./verify-build.sh
```

This script will:
- ✅ Check if the Xcode project exists
- ✅ Verify you're on macOS (required for iOS builds)
- ✅ Build the project using `xcodebuild`
- ✅ Report success or failure with error details

### Option 2: Using Xcode

1. Open `would_watch.xcodeproj` in Xcode
2. Press `⌘ + B` (or Product → Build)
3. Check the Issue Navigator (⌘ + 5) for any errors

### Option 3: Using Command Line

From the `ios` directory:

```bash
xcodebuild -project would_watch.xcodeproj -scheme would_watch -destination 'platform=iOS Simulator,name=iPhone 15' clean build
```

## What to Look For

### ✅ Success Indicators
- Build completes with "BUILD SUCCEEDED"
- No errors in the Issue Navigator
- Exit code 0 from build script

### ❌ Failure Indicators
- Build fails with "BUILD FAILED"
- Red errors in the Issue Navigator
- Exit code 1 from build script

## Common Issues

### Missing Imports
If you see errors about missing types (like `UIColor`, `ObservableObject`), check that:
- `UIKit` is imported where needed (with `#if canImport(UIKit)`)
- `Combine` is imported in ViewModels using `@Published`
- `SwiftUI` is imported in all View files

### Platform-Specific Code
The project supports multiple platforms. Use conditional compilation:
```swift
#if os(iOS)
// iOS-specific code
#endif

#if canImport(UIKit)
// Code that works on iOS/iPadOS
#endif
```

## Automated Checks

The build script (`verify-build.sh`) can be integrated into:
- CI/CD pipelines
- Pre-commit hooks
- Automated testing

Example CI integration:
```yaml
- name: Verify iOS Build
  run: |
    cd ios
    ./verify-build.sh
```
