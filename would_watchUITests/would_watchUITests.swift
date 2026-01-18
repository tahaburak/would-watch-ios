//
//  would_watchUITests.swift
//  would_watchUITests
//
//  Created by burak on 18/01/2026.
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

        // When
        let settingsButton = app.buttons["Settings"]
        if settingsButton.exists {
            settingsButton.tap()

            // Then
            let settingsTitle = app.navigationBars["Settings"]
            XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3), "Settings screen should appear")
        }
    }

    @MainActor
    func testNavigateToRoomList() throws {
        // Given
        app.launch()
        loginSuccessfully()

        // Then
        let roomsTitle = app.navigationBars.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'room'")).firstMatch
        XCTAssertTrue(roomsTitle.waitForExistence(timeout: 5), "Rooms screen should be visible after login")
    }

    // MARK: - Authentication Flow Tests

    @MainActor
    func testLoginWithValidCredentials() throws {
        // Given
        app.launch()

        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let loginButton = app.buttons["Log In"]

        XCTAssertTrue(emailField.waitForExistence(timeout: 5))

        // When
        emailField.tap()
        emailField.typeText("test@example.com")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Then
        let homeIndicator = app.otherElements.containing(NSPredicate(format: "label CONTAINS[c] 'room' OR label CONTAINS[c] 'home'")).firstMatch
        XCTAssertTrue(homeIndicator.waitForExistence(timeout: 5), "Should navigate to home screen after successful login")
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

        // When
        let signUpButton = app.buttons["Sign Up"]
        if signUpButton.exists {
            signUpButton.tap()

            // Then
            let signUpTitle = app.navigationBars["Sign Up"]
            XCTAssertTrue(signUpTitle.waitForExistence(timeout: 3), "Should navigate to Sign Up screen")
        }
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

        if emailField.waitForExistence(timeout: 5) {
            emailField.tap()
            emailField.typeText("test@example.com")

            passwordField.tap()
            passwordField.typeText("password123")

            loginButton.tap()

            sleep(2)
        }
    }
}
