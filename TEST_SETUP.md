# iOS Test Setup Guide

This guide explains how to set up and run the test suites for the would_watch iOS app.

## Overview

The test suite consists of:
- **Unit Tests** (`would_watchTests`): Test network layer, ViewModels, and business logic
- **UI Tests** (`would_watchUITests`): Test user flows and navigation

## Test Infrastructure

### Mock API Client
`MockAPIClient.swift` provides a mock implementation of `APIClientProtocol` for testing without hitting the real backend.

Features:
- Configurable success/failure responses
- Request tracking for verification
- Predefined mock data for common models
- Helper methods for setting up test scenarios

## Adding Test Targets to Xcode

### 1. Add Unit Test Target

1. Open `would_watch.xcodeproj` in Xcode
2. Select the project in the navigator
3. Click the "+" button at the bottom of the targets list
4. Choose "Unit Testing Bundle"
5. Name it `would_watchTests`
6. Set the target to be tested: `would_watch`
7. Click "Finish"

### 2. Add UI Test Target

1. Click the "+" button again
2. Choose "UI Testing Bundle"
3. Name it `would_watchUITests`
4. Set the target to be tested: `would_watch`
5. Click "Finish"

### 3. Add Test Files to Targets

1. In Xcode's Project Navigator, drag the following folders into your project:
   - `would_watchTests/` folder
   - `would_watchUITests/` folder
2. When prompted, ensure:
   - "Copy items if needed" is **unchecked** (files are already in the right location)
   - Add to targets: Check the appropriate test target for each folder
   - Create groups (not folder references)

### 4. Configure Test Target Settings

For `would_watchTests`:
1. Select the `would_watchTests` target
2. Go to "Build Settings"
3. Set "Bundle Identifier" to `com.yourcompany.would-watch.tests`
4. Go to "Build Phases" → "Compile Sources"
5. Ensure all test files are included:
   - `MockAPIClient.swift`
   - `NetworkLayerTests.swift`
   - `LoginViewModelTests.swift`
   - `RoomViewModelTests.swift`

For `would_watchUITests`:
1. Select the `would_watchUITests` target
2. Set "Bundle Identifier" to `com.yourcompany.would-watch.uitests`
3. Ensure `would_watchUITests.swift` is in "Compile Sources"

### 5. Link Main App to Test Targets

1. Select the `would_watchTests` target
2. Go to "Build Phases" → "Link Binary With Libraries"
3. Add `would_watch.app` if not already present
4. In "Build Settings", set "Host Application" to `would_watch`

## Running Tests

**IMPORTANT:** Tests must be run on an iOS Simulator, not a physical device. Make sure to select a simulator as the destination before running tests.

### Run in Xcode (Recommended)
1. Open the project in Xcode
2. **Select an iOS Simulator** from the destination dropdown at the top (e.g., "iPhone 15")
   - Make sure it says "Simulator" not a physical device
3. Clean the build folder: `Cmd+Shift+K`
4. Build the project: `Cmd+B`
5. Run tests: `Cmd+U` (or click the diamond icons next to test methods)

### Run from Command Line

**Using the provided script (easiest):**
```bash
cd /Users/burak/Documents/DEV/Projects/would_watch/ios
./run_tests.sh
```

**Run All Tests:**
```bash
xcodebuild test \
  -project would_watch.xcodeproj \
  -scheme would_watch \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Run Unit Tests Only:**
```bash
xcodebuild test \
  -project would_watch.xcodeproj \
  -scheme would_watch \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:would_watchTests
```

**Run UI Tests Only:**
```bash
xcodebuild test \
  -project would_watch.xcodeproj \
  -scheme would_watch \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:would_watchUITests
```

## Test Structure

### Unit Tests

#### NetworkLayerTests.swift
Tests for API client and network operations:
- Request construction (headers, URLs)
- JSON decoding for models (`User`, `Room`, `Media`)
- Error handling (network errors, decoding errors)

#### LoginViewModelTests.swift
Tests for login functionality:
- Successful login flow
- Loading state management
- Error handling (network errors, invalid credentials)
- Token management
- Input validation

#### RoomViewModelTests.swift
Tests for room management:
- Fetching room lists
- Creating rooms
- Fetching single room details
- Deleting rooms
- Error handling and retry logic

### UI Tests

#### would_watchUITests.swift
End-to-end user flow tests:
- App launch and initial screen
- Login flow with valid/invalid credentials
- Navigation between screens
- Settings screen access
- Room creation flow
- Accessibility checks

## Writing New Tests

### Unit Test Template
```swift
@MainActor
final class MyViewModelTests: XCTestCase {
    var viewModel: MyViewModel!
    var mockAPIClient: MockAPIClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        viewModel = MyViewModel(apiClient: mockAPIClient)
    }

    override func tearDown() {
        viewModel = nil
        mockAPIClient = nil
        super.tearDown()
    }

    func testSomething() async {
        // Given
        mockAPIClient.mockData = ...

        // When
        await viewModel.doSomething()

        // Then
        XCTAssertEqual(viewModel.result, expected)
    }
}
```

### UI Test Template
```swift
func testUserFlow() throws {
    // Given
    app.launch()

    // When
    let button = app.buttons["Button"]
    button.tap()

    // Then
    let resultLabel = app.staticTexts["Result"]
    XCTAssertTrue(resultLabel.waitForExistence(timeout: 5))
}
```

## Troubleshooting

### "Could not find test host" Error
This error occurs when tests try to run on a device instead of simulator:
- **Solution:** Select an iOS Simulator from the destination dropdown in Xcode
- In Xcode: Click the destination at the top and choose "iPhone 15" or any simulator
- From command line: Always include `-destination 'platform=iOS Simulator,name=iPhone 15'`
- The app must be built for simulator (`Debug-iphonesimulator`), not device (`Debug-iphoneos`)

### Tests Not Appearing
- Ensure test files are added to the correct target (check Target Membership in File Inspector)
- Clean build folder: `Cmd+Shift+K`
- Rebuild: `Cmd+B`

### Import Errors
- Make sure `@testable import would_watch` is at the top of test files
- Verify the main app module name matches

### UI Tests Failing
- Check that accessibility identifiers are set correctly in SwiftUI views
- Increase timeout values if tests are flaky
- Ensure simulator is running and responsive
- Make sure you're running on a simulator, not a device

### Mock Data Not Working
- Verify `MockAPIClient` is properly configured in `setUp()`
- Check that mock data matches expected model structure
- Use `try mockAPIClient.setMockResponse(mockObject)` for complex objects

## Continuous Integration

To run tests in CI:
```bash
#!/bin/bash
set -e

# Run unit tests
xcodebuild test \
  -project would_watch.xcodeproj \
  -scheme would_watch \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:would_watchTests \
  -resultBundlePath ./test-results/unit

# Run UI tests
xcodebuild test \
  -project would_watch.xcodeproj \
  -scheme would_watch \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:would_watchUITests \
  -resultBundlePath ./test-results/ui
```

## Best Practices

1. **Keep tests isolated**: Each test should be independent
2. **Use descriptive names**: `testLoginSuccessUpdatesAuthState()` not `testLogin()`
3. **Follow AAA pattern**: Arrange, Act, Assert (Given, When, Then)
4. **Mock external dependencies**: Never hit real APIs in tests
5. **Test edge cases**: Empty states, errors, boundary conditions
6. **Keep tests fast**: Unit tests should run in milliseconds
7. **Use async/await**: For testing async ViewModels
8. **Clean up**: Always implement `tearDown()` to reset state
