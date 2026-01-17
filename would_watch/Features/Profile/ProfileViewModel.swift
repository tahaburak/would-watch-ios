//
//  ProfileViewModel.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let profileService: ProfileServiceProtocol

    init(profileService: ProfileServiceProtocol = ProfileService()) {
        self.profileService = profileService
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            profile = try await profileService.getProfile()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func updatePrivacy(_ privacy: PrivacySetting) async {
        isLoading = true
        errorMessage = nil

        do {
            profile = try await profileService.updateProfile(privacy: privacy)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func updateUsername(_ username: String) async {
        guard !username.isEmpty else {
            errorMessage = "Username cannot be empty"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            profile = try await profileService.updateProfile(username: username)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
