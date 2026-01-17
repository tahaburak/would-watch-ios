//
//  MovieService.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation

protocol MovieServiceProtocol {
    func searchMovies(query: String) async throws -> [Movie]
    func getPopularMovies() async throws -> [Movie]
    func getMovieDetails(id: Int) async throws -> Movie
}

final class MovieService: MovieServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    func searchMovies(query: String) async throws -> [Movie] {
        struct Response: Codable {
            let results: [Movie]
        }

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let response: Response = try await apiClient.get(endpoint: "/media/search?q=\(encodedQuery)")
        return response.results
    }

    func getPopularMovies() async throws -> [Movie] {
        struct Response: Codable {
            let results: [Movie]
        }

        let response: Response = try await apiClient.get(endpoint: "/media/popular")
        return response.results
    }

    func getMovieDetails(id: Int) async throws -> Movie {
        return try await apiClient.get(endpoint: "/media/\(id)")
    }
}
