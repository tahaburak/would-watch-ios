//
//  VotingView.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import SwiftUI

struct VotingView: View {
    let roomId: String
    @StateObject private var movieViewModel = MovieViewModel()
    @StateObject private var roomViewModel = RoomViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var currentMovieIndex = 0
    @State private var dragOffset: CGSize = .zero
    @State private var showingSearch = false
    @State private var showMatch = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    if movieViewModel.movies.isEmpty {
                        emptyStateView
                    } else if currentMovieIndex < movieViewModel.movies.count {
                        movieCard(movieViewModel.movies[currentMovieIndex])
                        voteButtons
                    } else {
                        allDoneView
                    }
                }
                .padding()

                if showMatch {
                    matchOverlay
                }
            }
            .navigationTitle("Vote on Movies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showingSearch) {
                MovieSearchView { movie in
                    addMovieToVoting(movie)
                }
            }
            .task {
                await movieViewModel.loadPopularMovies()
            }
        }
    }

    @ViewBuilder
    private func movieCard(_ movie: Movie) -> some View {
        VStack(spacing: 0) {
            // Movie Poster
            if let posterURL = movie.posterURL {
                AsyncImage(url: posterURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(2/3, contentMode: .fit)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(2/3, contentMode: .fit)
                            .overlay(
                                Image(systemName: "film")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxHeight: 500)
                .clipped()
            }

            // Movie Info
            VStack(alignment: .leading, spacing: 12) {
                Text(movie.title)
                    .font(AppFonts.headlineMedium)
                    .fontWeight(.bold)

                if let rating = movie.voteAverage {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(.secondary)

                        if let year = movie.releaseDate?.prefix(4) {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(String(year))
                                .font(AppFonts.bodyMedium)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if let overview = movie.overview, !overview.isEmpty {
                    Text(overview)
                        .font(AppFonts.bodyMedium)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(radius: 10)
        .offset(dragOffset)
        .rotationEffect(.degrees(Double(dragOffset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    dragOffset = gesture.translation
                }
                .onEnded { gesture in
                    if abs(gesture.translation.width) > 100 {
                        let vote: VoteType = gesture.translation.width > 0 ? .yes : .no
                        handleVote(movie: movie, vote: vote)
                    } else {
                        withAnimation {
                            dragOffset = .zero
                        }
                    }
                }
        )
    }

    private var voteButtons: some View {
        HStack(spacing: 40) {
            // No Button
            Button(action: {
                if currentMovieIndex < movieViewModel.movies.count {
                    handleVote(movie: movieViewModel.movies[currentMovieIndex], vote: .no)
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(Color.red)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }

            // Yes Button
            Button(action: {
                if currentMovieIndex < movieViewModel.movies.count {
                    handleVote(movie: movieViewModel.movies[currentMovieIndex], vote: .yes)
                }
            }) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(Color.green)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "film.stack")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Movies to Vote On")
                .font(AppFonts.headlineSmall)
                .fontWeight(.semibold)

            Text("Search for movies to add to your voting list")
                .font(AppFonts.bodyMedium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {
                showingSearch = true
            }) {
                Text("Search Movies")
                    .font(AppFonts.labelLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    private var allDoneView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("All Done!")
                .font(AppFonts.headlineSmall)
                .fontWeight(.semibold)

            Text("You've voted on all available movies")
                .font(AppFonts.bodyMedium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {
                showingSearch = true
            }) {
                Text("Add More Movies")
                    .font(AppFonts.labelLarge)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    private var matchOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)

                Text("It's a Match!")
                    .font(AppFonts.displaySmall)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Someone else voted yes too!")
                    .font(AppFonts.bodyLarge)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
        }
        .transition(.opacity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showMatch = false
                }
            }
        }
    }

    private func handleVote(movie: Movie, vote: VoteType) {
        Task {
            do {
                let response = try await roomViewModel.roomService.submitVote(
                    roomId: roomId,
                    mediaId: movie.id,
                    vote: vote
                )

                withAnimation {
                    if vote == .yes {
                        dragOffset = CGSize(width: 500, height: 0)
                    } else {
                        dragOffset = CGSize(width: -500, height: 0)
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    dragOffset = .zero
                    currentMovieIndex += 1

                    if response.isMatch == true {
                        withAnimation {
                            showMatch = true
                        }
                    }
                }
            } catch {
                print("Vote error: \(error)")
            }
        }
    }

    private func addMovieToVoting(_ movie: Movie) {
        movieViewModel.movies.append(movie)
    }
}

#Preview {
    VotingView(roomId: "test-room")
}
