//
//  ProfileViewModel.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation
import Combine
import SwiftUI

final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let profileService: ProfileServiceProtocol

    init(profileService: ProfileServiceProtocol = ProfileService()) {
        self.profileService = profileService
    }

    @MainActor
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

    @MainActor
    func updatePrivacy(_ privacy: PrivacySetting) async {
        isLoading = true
        errorMessage = nil

        do {
            profile = try await profileService.updateProfile(username: nil, privacy: privacy)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func updateUsername(_ username: String) async {
        guard !username.isEmpty else {
            errorMessage = "Username cannot be empty"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            profile = try await profileService.updateProfile(username: username, privacy: nil)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
