//
//  ProfileService.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation

protocol ProfileServiceProtocol {
    func getProfile() async throws -> UserProfile
    func updateProfile(username: String?, privacy: PrivacySetting?) async throws -> UserProfile
}

final class ProfileService: ProfileServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    func getProfile() async throws -> UserProfile {
        return try await apiClient.get(endpoint: "/me/profile", headers: nil)
    }

    func updateProfile(username: String? = nil, privacy: PrivacySetting? = nil) async throws -> UserProfile {
        let request = UpdateProfileRequest(username: username, privacy: privacy)
        let response: UpdateProfileResponse = try await apiClient.put(endpoint: "/me/profile", body: request, headers: nil)
        return response.profile
    }
}
