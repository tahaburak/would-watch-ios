//
//  Friend.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation

struct Friend: Codable, Identifiable {
    let id: String
    let username: String
    let email: String?
    let avatarUrl: String?
    let isFollowing: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case avatarUrl = "avatar_url"
        case isFollowing = "is_following"
        case createdAt = "created_at"
    }
}

struct FollowRequest: Codable {
    let userId: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
    }
}

struct FollowResponse: Codable {
    let success: Bool
    let message: String?
}
