//
//  MatchesView.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct MatchesView: View {
    let roomId: String
    @StateObject private var roomViewModel = RoomViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var matches: [RoomMatch] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    ProgressView()
                } else if matches.isEmpty {
                    emptyStateView
                } else {
                    matchesList
                }
            }
            .navigationTitle("Matches")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
            .task {
                await loadMatches()
            }
            .refreshable {
                await loadMatches()
            }
        }
    }

    private var matchesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(matches) { match in
                    MatchCard(match: match)
                }
            }
            .padding()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Matches Yet")
                .font(AppFonts.headlineSmall)
                .fontWeight(.semibold)

            Text("Start voting on movies to find matches with your friends")
                .font(AppFonts.bodyMedium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }

    private func loadMatches() async {
        isLoading = true
        errorMessage = nil

        do {
            matches = try await roomViewModel.getMatches(roomId: roomId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

struct MatchCard: View {
    let match: RoomMatch

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Movie Poster
            if let posterURL = match.movie.posterURL {
                AsyncImage(url: posterURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(16/9, contentMode: .fit)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "film")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 200)
                .clipped()
            }

            // Movie Info
            VStack(alignment: .leading, spacing: 12) {
                // Title and Rating
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(match.movie.title)
                            .font(AppFonts.titleLarge)
                            .fontWeight(.bold)

                        if let rating = match.movie.voteAverage {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Text(String(format: "%.1f", rating))
                                    .font(AppFonts.bodyMedium)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    // Match Badge
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Match")
                            .font(AppFonts.labelMedium)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }

                // Overview
                if let overview = match.movie.overview, !overview.isEmpty {
                    Text(overview)
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }

                Divider()

                // Voters
                VStack(alignment: .leading, spacing: 8) {
                    Text("Voted Yes:")
                        .font(AppFonts.labelMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        ForEach(match.voters, id: \.self) { voter in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text(voter.prefix(1).uppercased())
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.blue)
                                    )

                                Text(voter)
                                    .font(AppFonts.bodySmall)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(voterBadgeBackgroundColor)
                            .cornerRadius(12)
                        }
                    }
                }

                // Actions
                HStack(spacing: 12) {
                    // TMDB Link
                    if let _ = match.movie.posterPath {
                        Link(destination: URL(string: "https://www.themoviedb.org/movie/\(match.movie.id)")!) {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle")
                                Text("TMDB")
                                    .font(AppFonts.labelSmall)
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }

                    Spacer()

                    // Share
                    ShareLink(item: "Check out \(match.movie.title) - we matched on Would Watch!") {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                                .font(AppFonts.labelSmall)
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(shareButtonBackgroundColor)
                        .cornerRadius(8)
                    }
                }
                .padding(.top, 4)
            }
            .padding()
        }
        .background(matchCardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    // MARK: - Background Colors
    private var voterBadgeBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGray6)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }

    private var shareButtonBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGray5)
        #else
        return Color.gray.opacity(0.15)
        #endif
    }

    private var matchCardBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #else
        return Color(white: 1.0)
        #endif
    }
}

#Preview {
    MatchesView(roomId: "test-room")
}
