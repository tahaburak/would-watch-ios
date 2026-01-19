//
//  APIClient.swift
//  would_watch
//
//  Created by Claude on 17/01/2026.
//

import Foundation

/// Protocol for URLSession-like objects to enable dependency injection and testing
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {
    // URLSession already conforms to URLSessionProtocol via its data(for:) method
}

protocol APIClientProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Data?,
        headers: [String: String]?
    ) async throws -> T
    
    // Convenience methods
    func get<T: Decodable>(endpoint: String, headers: [String: String]?) async throws -> T
    func post<T: Decodable, U: Encodable>(
        endpoint: String,
        body: U,
        headers: [String: String]?
    ) async throws -> T
    func put<T: Decodable, U: Encodable>(
        endpoint: String,
        body: U,
        headers: [String: String]?
    ) async throws -> T
    func delete<T: Decodable>(endpoint: String, headers: [String: String]?) async throws -> T
}

final class APIClient: APIClientProtocol {
    static let shared = APIClient()

    private let session: URLSessionProtocol
    private var authToken: String?

    init(session: URLSessionProtocol = URLSession.shared) {
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
        guard let url = URL(string: AppConfig.backendBaseURL + endpoint) else {
            print("❌ [APIClient] Invalid URL: \(AppConfig.backendBaseURL + endpoint)")
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
            print("🔐 [APIClient] Request with auth token")
        } else {
            print("⚠️ [APIClient] Request without auth token")
        }

        // Add custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Log request
        print("📤 [APIClient] \(method.rawValue) \(url.absoluteString)")
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            print("📦 [APIClient] Request body: \(bodyString)")
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            print("❌ [APIClient] Connection error: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain), Code: \(nsError.code)")
            }
            throw NetworkError.connectionError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [APIClient] Invalid response type")
            throw NetworkError.noData
        }

        // Log response
        print("📥 [APIClient] Response: \(httpResponse.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
        if let responseString = String(data: data, encoding: .utf8) {
            let preview = responseString.count > 500 ? String(responseString.prefix(500)) + "..." : responseString
            print("📦 [APIClient] Response body: \(preview)")
        } else {
            print("📦 [APIClient] Response body: <binary data, \(data.count) bytes>")
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let result = try decoder.decode(T.self, from: data)
                print("✅ [APIClient] Successfully decoded response")
                return result
            } catch {
                print("❌ [APIClient] Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("   Missing key: \(key.stringValue) at \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    case .typeMismatch(let type, let context):
                        print("   Type mismatch: expected \(type) at \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    case .valueNotFound(let type, let context):
                        print("   Value not found: \(type) at \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    case .dataCorrupted(let context):
                        print("   Data corrupted at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")): \(context.debugDescription)")
                    @unknown default:
                        print("   Unknown decoding error")
                    }
                }
                throw NetworkError.decodingError(error)
            }
        case 401:
            print("❌ [APIClient] Unauthorized (401)")
            throw NetworkError.unauthorized
        default:
            let errorMessage = String(data: data, encoding: .utf8)
            print("❌ [APIClient] Server error (\(httpResponse.statusCode)): \(errorMessage ?? "No error message")")
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
