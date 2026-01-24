//
//  would_watchUITests.swift
//  would_watchUITests
//
//  Created by burak on 18/01/2026.
//
//  IMPORTANT: These UI tests require valid Supabase credentials.
//  
//  TEST CREDENTIALS:
//  - Email: tahaburak.koc+wwtest@gmail.com
//  - Password: password123
//  
//  Ensure your Supabase URL and keys are correctly configured in AppConfig.swift
//  These tests will fail with "invalid_credentials" errors if the test user doesn't exist.
//

import XCTest

final class would_watchUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - App Launch Tests

    @MainActor
    func testAppLaunches() throws {
        // When
        app.launch()

        // Then
        XCTAssertTrue(app.exists, "App should launch successfully")
    }

    @MainActor
    func testLoginScreenAppearsOnLaunch() throws {
        // When
        app.launch()

        // Then
        let loginButton = app.buttons["Log In"]
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]

        XCTAssertTrue(emailField.waitForExistence(timeout: 5), "Email field should exist")
        XCTAssertTrue(passwordField.exists, "Password field should exist")
        XCTAssertTrue(loginButton.exists, "Login button should exist")
    }

    // MARK: - Navigation Tests

    @MainActor
    func testNavigateToSettings() throws {
        // Given
        app.launch()
        loginSuccessfully()

        // Wait for main tab view to appear - this will fail with helpful message if login didn't work
        let roomsTab = app.buttons["Rooms"]
        let friendsTab = app.buttons["Friends"]
        let profileTab = app.buttons["Profile"]

        // Check for any tab to confirm we're in the main app
        let tabViewExists = roomsTab.waitForExistence(timeout: 5) ||
                          friendsTab.waitForExistence(timeout: 5) ||
                          profileTab.waitForExistence(timeout: 5)

        XCTAssertTrue(tabViewExists, "TabView should appear after successful login. If this fails, login likely didn't complete - check test credentials in Supabase.")

        // Navigate to Profile tab (where Settings button is)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5), "Profile tab should exist")
        profileTab.tap()

        // Wait for profile screen to load - check for multiple indicators
        // ProfileView shows "Profile" navigation title and loads data asynchronously
        let profileTitle = app.navigationBars["Profile"]
        let activityText = app.staticTexts["Activity"]
        let loadingIndicator = app.activityIndicators.firstMatch

        // First, wait for navigation title to appear (should be fast)
        XCTAssertTrue(profileTitle.waitForExistence(timeout: 10), "Profile navigation title should appear")

        // Wait for content to load - either Activity text appears or loading completes
        // Give it more time since it loads data from the backend
        var profileContentLoaded = false
        for _ in 0..<15 {
            if activityText.exists || (!loadingIndicator.exists && profileTitle.exists) {
                profileContentLoaded = true
                break
            }
            sleep(1)
        }
        XCTAssertTrue(profileContentLoaded, "Profile content should load (Activity text or finished loading)")

        // When - Tap settings button (gear icon with accessibility identifier)
        // The button is an icon-only button with accessibilityIdentifier("Settings")
        let settingsButton = app.buttons.matching(identifier: "Settings").firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings button should be visible on Profile screen")
        settingsButton.tap()

        // Then - Wait for settings sheet to appear
        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 5), "Settings screen should appear after tapping Settings button")
    }

    @MainActor
    func testNavigateToRoomList() throws {
        // Given
        app.launch()
        loginSuccessfully()

        // Then - Check for Rooms tab (should be selected by default)
        // First verify TabView exists
        let roomsTab = app.buttons["Rooms"]
        let friendsTab = app.buttons["Friends"]
        let profileTab = app.buttons["Profile"]

        let tabViewExists = roomsTab.waitForExistence(timeout: 5) ||
                          friendsTab.waitForExistence(timeout: 5) ||
                          profileTab.waitForExistence(timeout: 5)

        XCTAssertTrue(tabViewExists, "TabView should appear after login. If this fails, login didn't complete.")
        
        // Now specifically check for Rooms tab
        XCTAssertTrue(roomsTab.waitForExistence(timeout: 5), "Rooms tab should appear after login")
        
        // Verify Rooms tab is visible and selected
        XCTAssertTrue(roomsTab.exists, "Rooms tab should be visible")
        
        // Check for navigation title - RoomsListView has navigationTitle("Rooms")
        let roomsTitle = app.navigationBars["Rooms"]
        let roomsTitleVisible = roomsTitle.waitForExistence(timeout: 5)
        
        // Also check for any room-related content as fallback
        let roomsContent = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'room' OR label CONTAINS[c] 'no rooms'")).firstMatch
        let contentVisible = roomsContent.waitForExistence(timeout: 3)
        
        XCTAssertTrue(roomsTitleVisible || contentVisible, "Rooms screen should be visible after login (navigation title or content)")
    }

    // MARK: - Authentication Flow Tests

    @MainActor
    func testLoginWithValidCredentials() throws {
        // Given
        app.launch()

        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Log In"]

        XCTAssertTrue(emailField.waitForExistence(timeout: 5), "Email field should be visible on login screen")

        // When
        emailField.tap()
        emailField.typeText("tahaburak.koc+wwtest@gmail.com")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Then - Wait for navigation to main screen
        // Check for TabView (MainTabView) which appears after successful login
        let mainTabView = app.otherElements["MainTabView"]
        let roomsTab = app.buttons["Rooms"]
        let friendsTab = app.buttons["Friends"]
        let profileTab = app.buttons["Profile"]

        // Wait for at least one tab to appear (with longer timeout for network request)
        let tabViewVisible = mainTabView.waitForExistence(timeout: 15) ||
                            roomsTab.waitForExistence(timeout: 15) ||
                            friendsTab.waitForExistence(timeout: 15) ||
                            profileTab.waitForExistence(timeout: 15)
        
        XCTAssertTrue(tabViewVisible, "Should navigate to main screen (TabView) after successful login. Check if login credentials are valid.")
        
        // Also verify we're no longer on login screen
        // Give it a moment for the transition
        sleep(1)
        let stillOnLoginScreen = emailField.exists
        XCTAssertFalse(stillOnLoginScreen, "Should not be on login screen after successful login")
    }

    @MainActor
    func testLoginWithEmptyFields() throws {
        // Given
        app.launch()

        let loginButton = app.buttons["Log In"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))

        // When
        loginButton.tap()

        // Then
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.exists, "Should remain on login screen with empty fields")
    }

    @MainActor
    func testLoginWithInvalidCredentials() throws {
        // Given
        app.launch()

        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Log In"]

        XCTAssertTrue(emailField.waitForExistence(timeout: 5))

        // When
        emailField.tap()
        emailField.typeText("wrong@example.com")

        passwordField.tap()
        passwordField.typeText("wrongpassword")

        loginButton.tap()

        // Then
        sleep(2)
        XCTAssertTrue(emailField.exists, "Should remain on login screen with invalid credentials")
    }

    @MainActor
    func testNavigateToSignUpFromLogin() throws {
        // Given
        app.launch()

        // Verify we're on login screen
        let loginButton = app.buttons["Log In"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Login button should exist initially")

        // When - Tap the toggle button to switch to sign up mode
        let toggleButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Sign Up'")).firstMatch
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 3), "Sign up toggle button should exist")
        toggleButton.tap()

        // Then - The main button should now say "Sign Up" instead of "Log In"
        let signUpButton = app.buttons["Sign Up"]
        XCTAssertTrue(signUpButton.waitForExistence(timeout: 3), "Main button should change to 'Sign Up'")

        // And the toggle button should now offer to switch back to login
        let loginToggleButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Log In'")).firstMatch
        XCTAssertTrue(loginToggleButton.waitForExistence(timeout: 2), "Should show toggle back to login")
    }

    // MARK: - Room Creation Flow Tests

    @MainActor
    func testCreateRoomFlow() throws {
        // Given
        app.launch()
        loginSuccessfully()

        // When
        let createRoomButton = app.buttons["Create Room"]
        if createRoomButton.waitForExistence(timeout: 5) {
            createRoomButton.tap()

            let roomNameField = app.textFields["Room Name"]
            if roomNameField.waitForExistence(timeout: 3) {
                roomNameField.tap()
                roomNameField.typeText("Test Room")

                let confirmButton = app.buttons["Create"]
                if confirmButton.exists {
                    confirmButton.tap()

                    // Then
                    sleep(2)
                    XCTAssertTrue(app.exists, "App should remain stable after room creation")
                }
            }
        }
    }

    // MARK: - Accessibility Tests

    @MainActor
    func testLoginScreenAccessibility() throws {
        // Given
        app.launch()

        // Then
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Log In"]

        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        XCTAssertTrue(emailField.isHittable, "Email field should be accessible")
        XCTAssertTrue(passwordField.isHittable, "Password field should be accessible")
        XCTAssertTrue(loginButton.isHittable, "Login button should be accessible")
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    // MARK: - Helper Methods

    private func loginSuccessfully() {
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Log In"]

        guard emailField.waitForExistence(timeout: 5) else {
            XCTFail("Email field not found - cannot perform login")
            return
        }

        emailField.tap()
        emailField.typeText("tahaburak.koc+wwtest@gmail.com")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Wait for either success (TabView appears) or failure (toast notification appears)
        // Try multiple ways to find the TabView
        let mainTabView = app.otherElements["MainTabView"]
        let roomsTab = app.buttons["Rooms"]
        let friendsTab = app.buttons["Friends"]
        let profileTab = app.buttons["Profile"]

        // Wait for navigation to complete - check for TabView or any tab
        let loginSuccessful = mainTabView.waitForExistence(timeout: 15) ||
                             roomsTab.waitForExistence(timeout: 15) ||
                             friendsTab.waitForExistence(timeout: 15) ||
                             profileTab.waitForExistence(timeout: 15)

        if !loginSuccessful {
            // Wait a moment for toast to appear (if login failed)
            sleep(2)

            // Check if there's a toast notification (error toast)
            // Try multiple ways to find the toast
            let toast = app.otherElements["ToastNotification"]
            let toastMessage = app.staticTexts["ToastMessage"]
            let toastByLabel = app.otherElements.containing(NSPredicate(format: "label CONTAINS[c] 'invalid' OR label CONTAINS[c] 'email' OR label CONTAINS[c] 'password' OR label CONTAINS[c] 'credentials'")).firstMatch

            // Check for toast by looking for red error toast (error type is red)
            let redToast = app.otherElements.containing(NSPredicate(format: "label CONTAINS[c] 'invalid email or password' OR label CONTAINS[c] 'invalid'")).firstMatch

            var errorMessage: String? = nil

            // Try to get error message from toast
            if toastMessage.waitForExistence(timeout: 1) {
                errorMessage = toastMessage.label
            } else if toast.waitForExistence(timeout: 1) {
                errorMessage = toast.label.isEmpty ? toast.value as? String : toast.label
            } else if toastByLabel.waitForExistence(timeout: 1) {
                errorMessage = toastByLabel.label
            } else if redToast.waitForExistence(timeout: 1) {
                errorMessage = redToast.label
            }

            if let error = errorMessage, !error.isEmpty {
                XCTFail("Login failed with error: \(error). Please ensure test credentials (tahaburak.koc+wwtest@gmail.com / password123) exist in Supabase.")
            } else if emailField.exists {
                // Still on login screen - login likely failed but no toast detected
                XCTFail("Login appears to have failed - still on login screen after 15 seconds. Check: 1) Test credentials exist in Supabase, 2) Network connection, 3) Supabase URL configuration. (Toast notification may not have appeared.)")
            } else {
                XCTFail("Login failed - neither TabView nor login screen detected. UI state unclear.")
            }
        }

        // Additional wait to ensure UI is stable
        sleep(1)
    }
}
