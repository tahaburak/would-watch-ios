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
    private let session: URLSessionProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared, session: URLSessionProtocol = URLSession.shared) {
        self.apiClient = apiClient
        self.session = session
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        // Call Supabase REST API directly for authentication
        let supabaseURL = AppConfig.supabaseURL
        let supabaseKey = AppConfig.supabaseAnonKey
        
        print("🔐 [AuthService] Attempting login for: \(email)")
        
        guard let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=password") else {
            print("❌ [AuthService] Invalid Supabase URL: \(supabaseURL)")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // For security, don't reveal whether user exists or not
            // Return generic error message for authentication failures
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 400 {
                // Check if it's an invalid credentials error
                if let errorResponse = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data),
                   let errorCode = errorResponse.errorCode ?? errorResponse.error,
                   (errorCode.contains("invalid") || errorCode.contains("credentials") || errorCode.contains("grant")) {
                    throw NetworkError.unauthorized
                }
                throw NetworkError.unauthorized
            }
            // Try to parse Supabase error response (OAuth2 format)
            var errorMessage = "Authentication failed"
            if let errorResponse = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                // Prefer error_description (OAuth2 standard) or message
                errorMessage = errorResponse.errorDescription ?? errorResponse.message ?? errorResponse.error ?? "Authentication failed"
            } else if let message = String(data: data, encoding: .utf8) {
                errorMessage = message
            }
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let supabaseResponse = try decoder.decode(SupabaseAuthResponse.self, from: data)
        let authResponse = AuthResponse(
            accessToken: supabaseResponse.accessToken,
            refreshToken: supabaseResponse.refreshToken,
            user: supabaseResponse.user
        )
        
        print("✅ [AuthService] Login successful for user: \(supabaseResponse.user.email)")
        
        // Store token in APIClient
        if let client = apiClient as? APIClient {
            client.setAuthToken(authResponse.accessToken)
        }

        // TODO: Store tokens securely in Keychain
        return authResponse
    }

    func signUp(email: String, password: String) async throws -> AuthResponse {
        // Call Supabase REST API directly for signup
        let supabaseURL = AppConfig.supabaseURL
        let supabaseKey = AppConfig.supabaseAnonKey
        
        print("🔐 [AuthService] Attempting signup for: \(email)")
        
        guard let url = URL(string: "\(supabaseURL)/auth/v1/signup") else {
            print("❌ [AuthService] Invalid Supabase URL: \(supabaseURL)")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            let errorMessage = String(data: data, encoding: .utf8) ?? "Signup failed"
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let supabaseResponse = try decoder.decode(SupabaseAuthResponse.self, from: data)
        let authResponse = AuthResponse(
            accessToken: supabaseResponse.accessToken,
            refreshToken: supabaseResponse.refreshToken,
            user: supabaseResponse.user
        )
        
        print("✅ [AuthService] Login successful for user: \(supabaseResponse.user.email)")
        
        // Store token in APIClient
        if let client = apiClient as? APIClient {
            client.setAuthToken(authResponse.accessToken)
        }

        // TODO: Store tokens securely in Keychain
        return authResponse
    }

    func logout() async throws {
        // Clear token from APIClient
        if let client = apiClient as? APIClient {
            client.setAuthToken(nil)
        }

        // TODO: Clear tokens from Keychain and call Supabase logout endpoint if needed
    }
}

// MARK: - Supabase Response Models

private struct SupabaseAuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case user
    }
}

private struct SupabaseErrorResponse: Codable {
    // OAuth2 error format (Supabase uses this)
    let error: String?
    let errorDescription: String?
    // Alternative formats
    let message: String?
    let code: String?
    let errorCode: String?
    
    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
        case message
        case code
        case errorCode = "error_code"
    }
}
