//
//  UserSearchView.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import SwiftUI

struct UserSearchView: View {
    @ObservedObject var viewModel: SocialViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchBar

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if viewModel.searchQuery.isEmpty {
                    emptySearchView
                } else if viewModel.searchResults.isEmpty {
                    noResultsView
                } else {
                    searchResultsList
                }
            }
            .navigationTitle("Find Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search by username or email", text: $viewModel.searchQuery)
                .textFieldStyle(PlainTextFieldStyle())
                .autocapitalization(.none)
                .onChange(of: viewModel.searchQuery) { _, _ in
                    Task {
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce
                        await viewModel.searchUsers()
                    }
                }

            if !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.searchQuery = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding()
    }

    private var searchResultsList: some View {
        List {
            ForEach(viewModel.searchResults) { user in
                UserSearchRowView(user: user) {
                    Task {
                        if user.isFollowing {
                            await viewModel.unfollowUser(user)
                        } else {
                            await viewModel.followUser(user)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    private var emptySearchView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("Search for Friends")
                .font(AppFonts.titleMedium)
                .fontWeight(.semibold)

            Text("Enter a username or email to find friends")
                .font(AppFonts.bodyMedium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No Results")
                .font(AppFonts.titleMedium)
                .fontWeight(.semibold)

            Text("No users found matching '\(viewModel.searchQuery)'")
                .font(AppFonts.bodyMedium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct UserSearchRowView: View {
    let user: Friend
    let onAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(user.username.prefix(1).uppercased())
                        .font(AppFonts.titleMedium)
                        .foregroundColor(.blue)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(user.username)
                    .font(AppFonts.bodyLarge)
                    .fontWeight(.medium)

                if let email = user.email {
                    Text(email)
                        .font(AppFonts.bodySmall)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button(action: onAction) {
                Text(user.isFollowing ? "Following" : "Follow")
                    .font(AppFonts.labelSmall)
                    .foregroundColor(user.isFollowing ? .gray : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(user.isFollowing ? Color.gray.opacity(0.2) : Color.blue)
                    .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    UserSearchView(viewModel: SocialViewModel())
}
