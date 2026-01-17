//
//  would_watchApp.swift
//  would_watch
//
//  Created by burak on 17/01/2026.
//

import SwiftUI

@main
struct would_watchApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var deepLinkHandler = DeepLinkHandler()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(deepLinkHandler)
                    .sheet(isPresented: $deepLinkHandler.showRoomLobby) {
                        if let roomId = deepLinkHandler.roomId {
                            NavigationView {
                                RealtimeLobbyView(roomId: roomId)
                            }
                        }
                    }
                    .onChange(of: authViewModel.isAuthenticated) { _, isAuthenticated in
                        if isAuthenticated {
                            deepLinkHandler.handlePendingDeepLink(isAuthenticated: true)
                        }
                    }
            } else {
                LoginView()
                    .environmentObject(authViewModel)
                    .environmentObject(deepLinkHandler)
            }
        }
        .onOpenURL { url in
            deepLinkHandler.handle(url, isAuthenticated: authViewModel.isAuthenticated)
        }
    }
}
