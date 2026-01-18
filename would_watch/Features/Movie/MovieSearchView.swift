//
//  MovieSearchView.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct MovieSearchView: View {
    @StateObject private var viewModel = MovieViewModel()
    @Environment(\.dismiss) var dismiss

    let onMovieSelected: ((Movie) -> Void)?

    init(onMovieSelected: ((Movie) -> Void)? = nil) {
        self.onMovieSelected = onMovieSelected
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchBar

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if viewModel.searchQuery.isEmpty {
                    popularMoviesView
                } else if viewModel.searchResults.isEmpty {
                    noResultsView
                } else {
                    searchResultsGrid
                }
            }
            .navigationTitle("Search Movies")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                #endif
            }
            .task {
                await viewModel.loadPopularMovies()
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search movies...", text: $viewModel.searchQuery)
                .textFieldStyle(PlainTextFieldStyle())
                #if os(iOS)
                .textInputAutocapitalization(.words)
                #endif
                .onChange(of: viewModel.searchQuery) { _, _ in
                    Task {
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s debounce
                        await viewModel.searchMovies()
                    }
                }

            if !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.searchQuery = ""
                    viewModel.searchResults = []
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(searchBarBackgroundColor)
        .cornerRadius(10)
        .padding()
    }

    private var popularMoviesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Popular Movies")
                    .font(AppFonts.headlineSmall)
                    .fontWeight(.semibold)
                    .padding(.horizontal)

                moviesGrid(movies: viewModel.movies)
            }
        }
    }

    private var searchResultsGrid: some View {
        ScrollView {
            moviesGrid(movies: viewModel.searchResults)
        }
    }

    private func moviesGrid(movies: [Movie]) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 16) {
            ForEach(movies) { movie in
                MovieGridItem(movie: movie) {
                    onMovieSelected?(movie)
                    dismiss()
                }
            }
        }
        .padding(.horizontal)
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "film.stack")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No Results")
                .font(AppFonts.titleMedium)
                .fontWeight(.semibold)

            Text("No movies found for '\(viewModel.searchQuery)'")
                .font(AppFonts.bodyMedium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MovieGridItem: View {
    let movie: Movie
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Poster
                if let posterURL = movie.posterURL {
                    AsyncImage(url: posterURL) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .aspectRatio(2/3, contentMode: .fit)
                                .overlay(
                                    ProgressView()
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .aspectRatio(2/3, contentMode: .fit)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .aspectRatio(2/3, contentMode: .fit)
                                .overlay(
                                    Image(systemName: "film")
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(2/3, contentMode: .fit)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "film")
                                .foregroundColor(.gray)
                        )
                }

                // Title
                Text(movie.title)
                    .font(AppFonts.bodySmall)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.primary)

                // Rating
                if let rating = movie.voteAverage {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(AppFonts.bodySmall)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private extension MovieSearchView {
    var searchBarBackgroundColor: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGray6)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }
}

#Preview {
    MovieSearchView()
}
