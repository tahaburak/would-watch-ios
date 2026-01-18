//
//  FriendsListView.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import SwiftUI

struct FriendsListView: View {
    @StateObject private var viewModel = SocialViewModel()
    @State private var showingSearch = false

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.friends.isEmpty {
                    ProgressView()
                } else if viewModel.friends.isEmpty {
                    emptyStateView
                } else {
                    friendsList
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSearch = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showingSearch = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingSearch) {
                UserSearchView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadFriends()
            }
            .refreshable {
                await viewModel.loadFriends()
            }
        }
    }

    private var friendsList: some View {
        List {
            ForEach(viewModel.friends) { friend in
                FriendRowView(friend: friend) {
                    Task {
                        await viewModel.unfollowUser(friend)
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Friends Yet")
                .font(AppFonts.headlineSmall)
                .fontWeight(.semibold)

            Text("Add friends to start watching together")
                .font(AppFonts.bodyMedium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {
                showingSearch = true
            }) {
                Text("Find Friends")
                    .font(AppFonts.labelLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .padding()
    }
}

struct FriendRowView: View {
    let friend: Friend
    let onUnfollow: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(friend.username.prefix(1).uppercased())
                        .font(AppFonts.titleMedium)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(friend.username)
                    .font(AppFonts.bodyLarge)
                    .fontWeight(.medium)

                if let email = friend.email {
                    Text(email)
                        .font(AppFonts.bodySmall)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button(action: onUnfollow) {
                Text("Unfollow")
                    .font(AppFonts.labelSmall)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FriendsListView()
}

