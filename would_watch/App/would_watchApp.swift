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

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
