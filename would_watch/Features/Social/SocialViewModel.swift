//
//  SocialViewModel.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation
import SwiftUI

@MainActor
final class SocialViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    @Published var searchResults: [Friend] = []
    @Published var searchQuery: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let socialService: SocialServiceProtocol

    init(socialService: SocialServiceProtocol = SocialService()) {
        self.socialService = socialService
    }

    func loadFriends() async {
        isLoading = true
        errorMessage = nil

        do {
            friends = try await socialService.getFriends()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func searchUsers() async {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            searchResults = try await socialService.searchUsers(query: searchQuery)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func followUser(_ user: Friend) async {
        do {
            _ = try await socialService.followUser(userId: user.id)
            // Update local state
            if let index = searchResults.firstIndex(where: { $0.id == user.id }) {
                searchResults[index] = Friend(
                    id: user.id,
                    username: user.username,
                    email: user.email,
                    avatarUrl: user.avatarUrl,
                    isFollowing: true,
                    createdAt: user.createdAt
                )
            }
            // Reload friends list
            await loadFriends()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func unfollowUser(_ user: Friend) async {
        do {
            _ = try await socialService.unfollowUser(userId: user.id)
            // Update local state
            if let index = friends.firstIndex(where: { $0.id == user.id }) {
                friends.remove(at: index)
            }
            if let index = searchResults.firstIndex(where: { $0.id == user.id }) {
                searchResults[index] = Friend(
                    id: user.id,
                    username: user.username,
                    email: user.email,
                    avatarUrl: user.avatarUrl,
                    isFollowing: false,
                    createdAt: user.createdAt
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
