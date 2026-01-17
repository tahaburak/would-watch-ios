//
//  DeepLinkHandler.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation
import SwiftUI

enum DeepLink: Equatable {
    case room(id: String)
    case profile(userId: String)
    case none

    static func parse(from url: URL) -> DeepLink {
        // Handle URL schemes: wouldwatch://room/{id}
        if url.scheme == "wouldwatch" {
            let components = url.pathComponents.filter { $0 != "/" }

            if components.count >= 2 {
                let action = components[0]
                let id = components[1]

                switch action {
                case "room":
                    return .room(id: id)
                case "profile":
                    return .profile(userId: id)
                default:
                    return .none
                }
            }
        }

        // Handle Universal Links: https://wouldwatch.app/join/{id}
        if url.host == "wouldwatch.app" || url.host == "www.wouldwatch.app" {
            let components = url.pathComponents.filter { $0 != "/" }

            if components.count >= 2 {
                let action = components[0]
                let id = components[1]

                switch action {
                case "join", "room":
                    return .room(id: id)
                case "profile", "user":
                    return .profile(userId: id)
                default:
                    return .none
                }
            }
        }

        return .none
    }
}

@MainActor
class DeepLinkHandler: ObservableObject {
    @Published var activeDeepLink: DeepLink = .none
    @Published var showRoomLobby: Bool = false
    @Published var roomId: String?

    func handle(_ url: URL, isAuthenticated: Bool) {
        let deepLink = DeepLink.parse(from: url)

        switch deepLink {
        case .room(let id):
            if isAuthenticated {
                // User is logged in, navigate to room
                roomId = id
                showRoomLobby = true
            } else {
                // User needs to login first, store the deep link
                activeDeepLink = deepLink
            }

        case .profile(let userId):
            // Handle profile deep link
            print("Navigate to profile: \(userId)")

        case .none:
            break
        }
    }

    func handlePendingDeepLink(isAuthenticated: Bool) {
        guard isAuthenticated, activeDeepLink != .none else { return }

        // After successful login, handle the pending deep link
        switch activeDeepLink {
        case .room(let id):
            roomId = id
            showRoomLobby = true
            activeDeepLink = .none

        case .profile(let userId):
            print("Navigate to profile: \(userId)")
            activeDeepLink = .none

        case .none:
            break
        }
    }

    func reset() {
        activeDeepLink = .none
        showRoomLobby = false
        roomId = nil
    }
}
