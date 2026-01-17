//
//  APIClient.swift
//  would_watch
//
//  Created by Claude on 17/01/2026.
//

import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Data?,
        headers: [String: String]?
    ) async throws -> T
}

final class APIClient: APIClientProtocol {
    static let shared = APIClient()

    private let baseURL: String
    private let session: URLSession
    private var authToken: String?

    init(baseURL: String = AppConfig.backendBaseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func setAuthToken(_ token: String?) {
        self.authToken = token
    }

    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authorization header if token exists
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        case 401:
            throw NetworkError.unauthorized
        default:
            let errorMessage = String(data: data, encoding: .utf8)
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
    }

    // Convenience methods
    func get<T: Decodable>(endpoint: String, headers: [String: String]? = nil) async throws -> T {
        try await request(endpoint: endpoint, method: .get, body: nil, headers: headers)
    }

    func post<T: Decodable, U: Encodable>(
        endpoint: String,
        body: U,
        headers: [String: String]? = nil
    ) async throws -> T {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(body)
        return try await request(endpoint: endpoint, method: .post, body: bodyData, headers: headers)
    }

    func put<T: Decodable, U: Encodable>(
        endpoint: String,
        body: U,
        headers: [String: String]? = nil
    ) async throws -> T {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try encoder.encode(body)
        return try await request(endpoint: endpoint, method: .put, body: bodyData, headers: headers)
    }

    func delete<T: Decodable>(endpoint: String, headers: [String: String]? = nil) async throws -> T {
        try await request(endpoint: endpoint, method: .delete, body: nil, headers: headers)
    }
}
