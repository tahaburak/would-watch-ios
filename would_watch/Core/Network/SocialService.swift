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
        let response: Response = try await apiClient.get(endpoint: "/social/friends")
        return response.friends
    }

    func searchUsers(query: String) async throws -> [Friend] {
        struct Response: Codable {
            let users: [Friend]
        }
        let response: Response = try await apiClient.get(
            endpoint: "/social/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
        )
        return response.users
    }

    func followUser(userId: String) async throws -> FollowResponse {
        let request = FollowRequest(userId: userId)
        return try await apiClient.post(endpoint: "/social/follow", body: request)
    }

    func unfollowUser(userId: String) async throws -> FollowResponse {
        let request = FollowRequest(userId: userId)
        return try await apiClient.post(endpoint: "/social/unfollow", body: request)
    }
}
