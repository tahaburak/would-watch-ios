//
//  MovieViewModel.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class MovieViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var searchResults: [Movie] = []
    @Published var searchQuery: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let movieService: MovieServiceProtocol

    init(movieService: MovieServiceProtocol = MovieService()) {
        self.movieService = movieService
    }

    func loadPopularMovies() async {
        isLoading = true
        errorMessage = nil

        do {
            movies = try await movieService.getPopularMovies()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func searchMovies() async {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            searchResults = try await movieService.searchMovies(query: searchQuery)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func getMovieDetails(id: Int) async -> Movie? {
        do {
            return try await movieService.getMovieDetails(id: id)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
