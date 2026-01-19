//
//  AuthViewModelTests.swift
//  would_watchTests
//
//  Created by Claude on 18/01/2026.
//

import XCTest
@testable import would_watch

@MainActor
final class AuthViewModelTests: XCTestCase {
    var viewModel: AuthViewModel!
    var mockAPIClient: MockAPIClient!
    var mockSession: URLSessionMock!
    var authService: AuthService!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        mockSession = URLSessionMock()
        authService = AuthService(apiClient: mockAPIClient, session: mockSession)
        viewModel = AuthViewModel(authService: authService)
    }

    override func tearDown() {
        viewModel = nil
        authService = nil
        mockAPIClient = nil
        mockSession = nil
        super.tearDown()
    }

    // MARK: - Login Success Tests

    func testLoginSuccess() async {
        // Given
        let email = "test@example.com"
        let password = "password123"
        let expectedToken = "test-token-123"

        // Mock Supabase response
        let supabaseResponse = """
        {
            "access_token": "\(expectedToken)",
            "refresh_token": "refresh-token",
            "user": {
                "id": "user-123",
                "email": "\(email)",
                "created_at": "2026-01-19T12:00:00Z"
            }
        }
        """
        mockSession.data = supabaseResponse.data(using: String.Encoding.utf8)!
        mockSession.response = HTTPURLResponse(
            url: URL(string: "\(AppConfig.supabaseURL)/auth/v1/token")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        viewModel.email = email
        viewModel.password = password

        // When
        await viewModel.login()

        // Then
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after login completes")
        XCTAssertTrue(viewModel.isAuthenticated, "User should be authenticated")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil on success")
    }

    func testLoginUpdatesLoadingState() async {
        // Given
        let email = "test@example.com"
        let password = "password123"
        let supabaseResponse = """
        {
            "access_token": "token",
            "refresh_token": "refresh",
            "user": {
                "id": "1",
                "email": "\(email)",
                "created_at": "2026-01-19T12:00:00Z"
            }
        }
        """
        mockSession.data = supabaseResponse.data(using: String.Encoding.utf8)!
        mockSession.response = HTTPURLResponse(
            url: URL(string: "\(AppConfig.supabaseURL)/auth/v1/token")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        viewModel.email = email
        viewModel.password = password

        // When/Then
        XCTAssertFalse(viewModel.isLoading, "Loading should be false before login")

        let loginTask = Task {
            await viewModel.login()
        }

        // Give a moment for state to update
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds

        await loginTask.value

        XCTAssertFalse(viewModel.isLoading, "Loading should be false after login")
    }

    // MARK: - Login Failure Tests

    func testLoginFailureWithNetworkError() async {
        // Given
        let email = "test@example.com"
        let password = "wrongpassword"

        mockSession.error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)

        viewModel.email = email
        viewModel.password = password

        // When
        await viewModel.login()

        // Then
        XCTAssertFalse(viewModel.isLoading, "Loading should be false after error")
        XCTAssertFalse(viewModel.isAuthenticated, "User should not be authenticated")
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set")
    }

    func testLoginFailureWithInvalidCredentials() async {
        // Given
        let email = "test@example.com"
        let password = "wrongpassword"

        // Mock Supabase error response
        mockSession.data = """
        {
            "error": "invalid_grant",
            "error_description": "Invalid email or password"
        }
        """.data(using: String.Encoding.utf8)!
        mockSession.response = HTTPURLResponse(
            url: URL(string: "\(AppConfig.supabaseURL)/auth/v1/token")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )

        viewModel.email = email
        viewModel.password = password

        // When
        await viewModel.login()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    // MARK: - Validation Tests

    func testLoginValidationFailsWithEmptyEmail() async {
        // Given
        viewModel.email = ""
        viewModel.password = "password123"

        // When
        await viewModel.login()

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Email") ?? false)
    }

    func testLoginValidationFailsWithEmptyPassword() async {
        // Given
        viewModel.email = "test@example.com"
        viewModel.password = ""

        // When
        await viewModel.login()

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Password") ?? false)
    }

    func testLoginValidationFailsWithInvalidEmailFormat() async {
        // Given
        viewModel.email = "notanemail"
        viewModel.password = "password123"

        // When
        await viewModel.login()

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("email") ?? false)
    }

    func testLoginValidationFailsWithShortPassword() async {
        // Given
        viewModel.email = "test@example.com"
        viewModel.password = "12345" // Only 5 characters

        // When
        await viewModel.login()

        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("6") ?? false)
    }

    // MARK: - Error Message Clearing Tests

    func testErrorMessageClearsOnRetry() async {
        // Given - First login fails
        mockSession.data = """
        {
            "error": "invalid_grant",
            "error_description": "Invalid email or password"
        }
        """.data(using: String.Encoding.utf8)!
        mockSession.response = HTTPURLResponse(
            url: URL(string: "\(AppConfig.supabaseURL)/auth/v1/token")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )
        viewModel.email = "test@example.com"
        viewModel.password = "wrongpassword"

        await viewModel.login()
        XCTAssertNotNil(viewModel.errorMessage)

        // When - Retry with success
        let supabaseResponse = """
        {
            "access_token": "token",
            "refresh_token": "refresh",
            "user": {
                "id": "1",
                "email": "test@example.com",
                "created_at": "2026-01-19T12:00:00Z"
            }
        }
        """
        mockSession.data = supabaseResponse.data(using: String.Encoding.utf8)!
        mockSession.response = HTTPURLResponse(
            url: URL(string: "\(AppConfig.supabaseURL)/auth/v1/token")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        viewModel.password = "correctpassword"

        await viewModel.login()

        // Then
        XCTAssertNil(viewModel.errorMessage, "Error message should clear on successful retry")
        XCTAssertTrue(viewModel.isAuthenticated)
    }

    // MARK: - Sign Up Tests

    func testSignUpSuccess() async {
        // Given
        let email = "newuser@example.com"
        let password = "password123"

        let supabaseResponse = """
        {
            "access_token": "token",
            "refresh_token": "refresh",
            "user": {
                "id": "new-user-id",
                "email": "\(email)",
                "created_at": "2026-01-19T12:00:00Z"
            }
        }
        """
        mockSession.data = supabaseResponse.data(using: String.Encoding.utf8)!
        mockSession.response = HTTPURLResponse(
            url: URL(string: "\(AppConfig.supabaseURL)/auth/v1/signup")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        viewModel.email = email
        viewModel.password = password

        // When
        await viewModel.signUp()

        // Then
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNotNil(viewModel.currentUser)
        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Logout Tests

    func testLogoutSuccess() async {
        // Given - User is logged in
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        viewModel.isAuthenticated = true
        viewModel.currentUser = User(id: "1", email: "test@example.com", createdAt: nil)

        // When
        await viewModel.logout()

        // Then
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.currentUser)
        XCTAssertTrue(viewModel.email.isEmpty)
        XCTAssertTrue(viewModel.password.isEmpty)
    }
}
