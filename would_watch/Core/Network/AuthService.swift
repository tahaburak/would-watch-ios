//
//  AuthService.swift
//  would_watch
//
//  Created by Claude on 17/01/2026.
//

import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> AuthResponse
    func signUp(email: String, password: String) async throws -> AuthResponse
    func logout() async throws
}

final class AuthService: AuthServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await apiClient.post(
            endpoint: "/auth/login",
            body: request,
            headers: nil
        )

        // Store token in APIClient
        if let client = apiClient as? APIClient {
            client.setAuthToken(response.accessToken)
        }

        // TODO: Store tokens securely in Keychain
        return response
    }

    func signUp(email: String, password: String) async throws -> AuthResponse {
        let request = SignUpRequest(email: email, password: password)
        let response: AuthResponse = try await apiClient.post(
            endpoint: "/auth/signup",
            body: request,
            headers: nil
        )

        // Store token in APIClient
        if let client = apiClient as? APIClient {
            client.setAuthToken(response.accessToken)
        }

        // TODO: Store tokens securely in Keychain
        return response
    }

    func logout() async throws {
        // Clear token from APIClient
        if let client = apiClient as? APIClient {
            client.setAuthToken(nil)
        }

        // TODO: Clear tokens from Keychain
    }
}
