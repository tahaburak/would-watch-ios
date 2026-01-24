//
//  SocialService.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation

protocol SocialServiceProtocol {
    func getFriends() async throws -> [Friend]
    func searchUsers(query: String) async throws -> [Friend]
    func followUser(userId: String) async throws -> FollowResponse
    func unfollowUser(userId: String) async throws -> FollowResponse
}

final class SocialService: SocialServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    func getFriends() async throws -> [Friend] {
        struct Response: Codable {
            let friends: [Friend]
        }
        let response: Response = try await apiClient.get(endpoint: "/me/following", headers: nil)
        return response.friends
    }

    func searchUsers(query: String) async throws -> [Friend] {
        struct Response: Codable {
            let users: [Friend]
        }
        let response: Response = try await apiClient.get(
            endpoint: "/users/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)",
            headers: nil
        )
        return response.users
    }

    func followUser(userId: String) async throws -> FollowResponse {
        // Backend expects: POST /api/follows/{userId} (userId in URL, not body)
        struct EmptyBody: Codable {}
        return try await apiClient.post(endpoint: "/follows/\(userId)", body: EmptyBody(), headers: nil)
    }

    func unfollowUser(userId: String) async throws -> FollowResponse {
        // Backend expects: DELETE /api/follows/{userId} (userId in URL, not body)
        return try await apiClient.delete(endpoint: "/follows/\(userId)", headers: nil)
    }
}
