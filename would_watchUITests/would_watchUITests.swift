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
        XCTAssertTrue(profileTab.waitForExistence(timeout: 3), "Profile tab should exist")
        profileTab.tap()

        // Wait for profile screen to load
        let profileTitle = app.navigationBars["Profile"]
        XCTAssertTrue(profileTitle.waitForExistence(timeout: 3), "Profile navigation title should appear")

        // When - Tap settings button
        let settingsButton = app.buttons.matching(identifier: "Settings").firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 3), "Settings button should be visible")
        settingsButton.tap()

        // Then
        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 2), "Settings screen should appear")
    }

    @MainActor
    func testNavigateToRoomList() throws {
        // Given
        app.launch()
        loginSuccessfully()

        // Then
        let roomsTab = app.buttons["Rooms"]
        XCTAssertTrue(roomsTab.waitForExistence(timeout: 3), "Rooms tab should appear after login")

        let roomsTitle = app.navigationBars["Rooms"]
        XCTAssertTrue(roomsTitle.waitForExistence(timeout: 3), "Rooms screen should be visible")
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
        let roomsTab = app.buttons["Rooms"]
        XCTAssertTrue(roomsTab.waitForExistence(timeout: 5), "Should navigate to main screen after successful login")
        XCTAssertFalse(emailField.exists, "Should not be on login screen after successful login")
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

        XCTAssertTrue(emailField.waitForExistence(timeout: 3))

        // When
        emailField.tap()
        emailField.typeText("wrong@example.com")

        passwordField.tap()
        passwordField.typeText("wrongpassword")

        loginButton.tap()

        // Then - Should remain on login screen
        XCTAssertTrue(emailField.waitForExistence(timeout: 3), "Should remain on login screen with invalid credentials")
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
        if createRoomButton.waitForExistence(timeout: 3) {
            createRoomButton.tap()

            let roomNameField = app.textFields["Room Name"]
            if roomNameField.waitForExistence(timeout: 2) {
                roomNameField.tap()
                roomNameField.typeText("Test Room")

                let confirmButton = app.buttons["Create"]
                if confirmButton.exists {
                    confirmButton.tap()
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

        guard emailField.waitForExistence(timeout: 3) else {
            XCTFail("Email field not found")
            return
        }

        emailField.tap()
        emailField.typeText("tahaburak.koc+wwtest@gmail.com")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Wait for navigation to complete
        let roomsTab = app.buttons["Rooms"]
        if !roomsTab.waitForExistence(timeout: 5) {
            XCTFail("Login failed - check credentials and network connection")
        }
    }
}
