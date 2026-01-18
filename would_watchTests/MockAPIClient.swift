//
//  MockAPIClient.swift
//  would_watchTests
//
//  Created by Claude on 18/01/2026.
//

import Foundation
@testable import would_watch

/// Mock implementation of APIClientProtocol for testing
class MockAPIClient: APIClientProtocol {
    // Control mock behavior
    var shouldFail = false
    var mockError: Error?
    var requestCallCount = 0
    var lastEndpoint: String?
    var lastMethod: HTTPMethod?

    // Predefined mock responses
    var mockAuthResponse: AuthResponse?
    var mockUser: User?
    var mockRooms: [Room] = []
    var mockRoom: Room?

    // MARK: - APIClientProtocol Implementation

    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Data?,
        headers: [String: String]?
    ) async throws -> T {
        requestCallCount += 1
        lastEndpoint = endpoint
        lastMethod = method

        // Simulate failure
        if shouldFail {
            throw mockError ?? NetworkError.connectionError(NSError(domain: "MockError", code: -1))
        }

        // Return appropriate mock data based on type
        if let response = try mockResponseFor(type: T.self) {
            return response
        }

        throw NetworkError.decodingError(NSError(domain: "MockError", code: -2))
    }

    func get<T: Decodable>(endpoint: String, headers: [String: String]?) async throws -> T {
        return try await request(endpoint: endpoint, method: .get, body: nil, headers: headers)
    }

    func post<T: Decodable, U: Encodable>(
        endpoint: String,
        body: U,
        headers: [String: String]?
    ) async throws -> T {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(body)
        return try await request(endpoint: endpoint, method: .post, body: bodyData, headers: headers)
    }

    func put<T: Decodable, U: Encodable>(
        endpoint: String,
        body: U,
        headers: [String: String]?
    ) async throws -> T {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(body)
        return try await request(endpoint: endpoint, method: .put, body: bodyData, headers: headers)
    }

    func delete<T: Decodable>(endpoint: String, headers: [String: String]?) async throws -> T {
        return try await request(endpoint: endpoint, method: .delete, body: nil, headers: headers)
    }

    // MARK: - Helper Methods

    private func mockResponseFor<T: Decodable>(type: T.Type) throws -> T? {
        // Auth responses
        if T.self == AuthResponse.self, let authResponse = mockAuthResponse {
            return authResponse as? T
        }

        // User responses
        if T.self == User.self, let user = mockUser {
            return user as? T
        }

        // Room array responses
        if T.self == [Room].self {
            return mockRooms as? T
        }

        // Single room responses
        if T.self == Room.self, let room = mockRoom {
            return room as? T
        }

        return nil
    }

    func reset() {
        shouldFail = false
        mockError = nil
        requestCallCount = 0
        lastEndpoint = nil
        lastMethod = nil
        mockAuthResponse = nil
        mockUser = nil
        mockRooms = []
        mockRoom = nil
    }
}
