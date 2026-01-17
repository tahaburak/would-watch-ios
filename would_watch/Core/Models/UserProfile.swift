//
//  UserProfile.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation

struct UserProfile: Codable {
    let id: String
    let username: String
    let email: String
    let avatarUrl: String?
    let privacy: PrivacySetting
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case avatarUrl = "avatar_url"
        case privacy
        case createdAt = "created_at"
    }
}

enum PrivacySetting: String, Codable, CaseIterable {
    case everyone = "everyone"
    case friends = "friends"
    case none = "none"

    var displayName: String {
        switch self {
        case .everyone:
            return "Everyone"
        case .friends:
            return "Friends Only"
        case .none:
            return "Private"
        }
    }

    var description: String {
        switch self {
        case .everyone:
            return "Anyone can see your profile and activity"
        case .friends:
            return "Only friends can see your profile"
        case .none:
            return "Your profile is completely private"
        }
    }
}

struct UpdateProfileRequest: Codable {
    let username: String?
    let privacy: PrivacySetting?
}

struct UpdateProfileResponse: Codable {
    let profile: UserProfile
}
