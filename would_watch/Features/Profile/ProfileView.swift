//
//  ProfileView.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let profile = viewModel.profile {
                    profileContent(profile)
                } else {
                    Text("Unable to load profile")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                    .accessibilityIdentifier("Settings")
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                    .accessibilityIdentifier("Settings")
                }
                #endif
            }
            .sheet(isPresented: $showingSettings) {
                SettingsSheet(viewModel: viewModel, authViewModel: authViewModel)
            }
            .task {
                await viewModel.loadProfile()
            }
        }
    }

    @ViewBuilder
    private func profileContent(_ profile: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Avatar
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(profile.username.prefix(1).uppercased())
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .padding(.top, 20)

                // Username
                VStack(spacing: 8) {
                    Text(profile.username)
                        .font(AppFonts.headlineMedium)
                        .fontWeight(.bold)

                    Text(profile.email)
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(.secondary)
                }

                // Privacy Badge
                HStack {
                    Image(systemName: privacyIcon(for: profile.privacy))
                        .foregroundColor(.blue)
                    Text(profile.privacy.displayName)
                        .font(AppFonts.labelMedium)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)

                Divider()
                    .padding(.horizontal)

                // Stats Section (Placeholder)
                VStack(spacing: 16) {
                    Text("Activity")
                        .font(AppFonts.titleLarge)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    HStack(spacing: 20) {
                        StatView(title: "Friends", value: "0")
                        StatView(title: "Rooms", value: "0")
                        StatView(title: "Matches", value: "0")
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
    }

    private func privacyIcon(for privacy: PrivacySetting) -> String {
        switch privacy {
        case .everyone:
            return "globe"
        case .friends:
            return "person.2"
        case .none:
            return "lock"
        }
    }
}

struct StatView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(AppFonts.headlineSmall)
                .fontWeight(.bold)

            Text(title)
                .font(AppFonts.bodySmall)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(statBackgroundColor)
        .cornerRadius(12)
    }
}

private extension StatView {
    var statBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGray6)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}

