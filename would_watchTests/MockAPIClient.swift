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
    var mockFriends: [Friend] = []
    var mockFollowResponse: FollowResponse?
    var mockData: Data?

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

        // Friend array responses (wrapped in response structure)
        if let typeName = String(reflecting: T.self).components(separatedBy: ".").last,
           typeName.contains("Response") {
            // Handle wrapped responses like SocialService.getFriends().Response
            if let mockData = mockData {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try? decoder.decode(T.self, from: mockData)
            }
        }

        // FollowResponse
        if T.self == FollowResponse.self, let followResponse = mockFollowResponse {
            return followResponse as? T
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
        mockFriends = []
        mockFollowResponse = nil
        mockData = nil
    }

    // MARK: - Test Helper Methods

    /// Set mock response for getFriends endpoint
    func setMockFriendsResponse(_ friends: [Friend]) throws {
        struct Response: Codable {
            let friends: [Friend]
        }
        let response = Response(friends: friends)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        mockData = try encoder.encode(response)
    }

    /// Set mock response for searchUsers endpoint
    func setMockSearchUsersResponse(_ users: [Friend]) throws {
        struct Response: Codable {
            let users: [Friend]
        }
        let response = Response(users: users)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        mockData = try encoder.encode(response)
    }

    /// Create a mock Friend for testing
    static func createMockFriend(
        id: String = "friend-1",
        username: String = "testuser",
        email: String? = "test@example.com",
        avatarUrl: String? = nil,
        isFollowing: Bool = false,
        createdAt: Date? = Date()
    ) -> Friend {
        return Friend(
            id: id,
            username: username,
            email: email,
            avatarUrl: avatarUrl,
            isFollowing: isFollowing,
            createdAt: createdAt
        )
    }
}
