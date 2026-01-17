//
//  MainTabView.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            RoomsListView()
                .tabItem {
                    Label("Rooms", systemImage: "rectangle.stack")
                }
                .tag(0)

            FriendsListView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
