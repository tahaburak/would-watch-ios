//
//  NetworkLayerTests.swift
//  would_watchTests
//
//  Created by Claude on 19/01/2026.
//

import XCTest
@testable import would_watch

@MainActor
final class NetworkLayerTests: XCTestCase {

    // MARK: - URL Construction Tests

    func testAPIClientConstructsValidURL() async {
        // Given
        let mockSession = URLSessionMock()
        let apiClient = APIClient(session: mockSession)
        let endpoint = "/api/auth/login"

        mockSession.data = try! JSONEncoder().encode(["message": "test"])
        mockSession.response = HTTPURLResponse(
            url: URL(string: AppConfig.backendBaseURL + endpoint)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When/Then - should not throw
        do {
            let _: [String: String] = try await apiClient.get(endpoint: endpoint, headers: nil)

            // Verify URL was constructed correctly
            XCTAssertNotNil(mockSession.lastRequest)
            XCTAssertEqual(mockSession.lastRequest?.url?.absoluteString, AppConfig.backendBaseURL + endpoint)
        } catch {
            XCTFail("Should construct valid URL without throwing: \(error)")
        }
    }

    func testAPIClientAddsContentTypeHeader() async {
        // Given
        let mockSession = URLSessionMock()
        let apiClient = APIClient(session: mockSession)

        mockSession.data = try! JSONEncoder().encode(["message": "test"])
        mockSession.response = HTTPURLResponse(
            url: URL(string: AppConfig.backendBaseURL + "/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        do {
            let _: [String: String] = try await apiClient.get(endpoint: "/test", headers: nil)

            // Then
            XCTAssertEqual(mockSession.lastRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        } catch {
            XCTFail("Request should succeed: \(error)")
        }
    }

    func testAPIClientAddsAuthorizationHeader() async {
        // Given
        let mockSession = URLSessionMock()
        let apiClient = APIClient(session: mockSession)
        let token = "test-token-123"

        mockSession.data = try! JSONEncoder().encode(["message": "test"])
        mockSession.response = HTTPURLResponse(
            url: URL(string: AppConfig.backendBaseURL + "/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        apiClient.setAuthToken(token)

        do {
            let _: [String: String] = try await apiClient.get(endpoint: "/test", headers: nil)

            // Then
            XCTAssertEqual(mockSession.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer \(token)")
        } catch {
            XCTFail("Request should succeed: \(error)")
        }
    }

    func testAPIClientAddsCustomHeaders() async {
        // Given
        let mockSession = URLSessionMock()
        let apiClient = APIClient(session: mockSession)
        let customHeaders = ["X-Custom-Header": "custom-value"]

        mockSession.data = try! JSONEncoder().encode(["message": "test"])
        mockSession.response = HTTPURLResponse(
            url: URL(string: AppConfig.backendBaseURL + "/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        do {
            let _: [String: String] = try await apiClient.get(endpoint: "/test", headers: customHeaders)

            // Then
            XCTAssertEqual(mockSession.lastRequest?.value(forHTTPHeaderField: "X-Custom-Header"), "custom-value")
        } catch {
            XCTFail("Request should succeed: \(error)")
        }
    }

    // MARK: - JSON Decoding Tests

    func testDecodesUserModel() async {
        // Given
        let mockSession = URLSessionMock()
        let apiClient = APIClient(session: mockSession)

        let userJSON = """
        {
            "id": "user-123",
            "email": "test@example.com",
            "created_at": "2026-01-19T12:00:00Z"
        }
        """

        mockSession.data = userJSON.data(using: .utf8)!
        mockSession.response = HTTPURLResponse(
            url: URL(string: AppConfig.backendBaseURL + "/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        do {
            let user: User = try await apiClient.get(endpoint: "/test", headers: nil)

            // Then
            XCTAssertEqual(user.id, "user-123")
            XCTAssertEqual(user.email, "test@example.com")
            XCTAssertNotNil(user.createdAt)
        } catch {
            XCTFail("Should decode User model: \(error)")
        }
    }

    func testDecodesRoomModel() async {
        // Given
        let mockSession = URLSessionMock()
        let apiClient = APIClient(session: mockSession)

        let roomJSON = """
        {
            "id": "room-123",
            "name": "Test Room",
            "host_id": "user-123",
            "status": "active",
            "created_at": "2026-01-19T12:00:00Z",
            "participants": ["user-123", "user-456"]
        }
        """

        mockSession.data = roomJSON.data(using: .utf8)!
        mockSession.response = HTTPURLResponse(
            url: URL(string: AppConfig.backendBaseURL + "/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        do {
            let room: Room = try await apiClient.get(endpoint: "/test", headers: nil)

            // Then
            XCTAssertEqual(room.id, "room-123")
            XCTAssertEqual(room.name, "Test Room")
            XCTAssertEqual(room.hostId, "user-123")
            XCTAssertEqual(room.status, .active)
        } catch {
            XCTFail("Should decode Room model: \(error)")
        }
    }

    func testDecodesMovieModel() async {
        // Given
        let mockSession = URLSessionMock()
        let apiClient = APIClient(session: mockSession)

        let movieJSON = """
        {
            "id": 550,
            "title": "Fight Club",
            "overview": "An insomniac office worker...",
            "poster_path": "/poster.jpg",
            "backdrop_path": "/backdrop.jpg",
            "release_date": "1999-10-15",
            "vote_average": 8.4,
            "vote_count": 20000
        }
        """

        mockSession.data = movieJSON.data(using: .utf8)!
        mockSession.response = HTTPURLResponse(
            url: URL(string: AppConfig.backendBaseURL + "/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        do {
            let movie: Movie = try await apiClient.get(endpoint: "/test", headers: nil)

            // Then
            XCTAssertEqual(movie.id, 550)
            XCTAssertEqual(movie.title, "Fight Club")
            XCTAssertEqual(movie.posterPath, "/poster.jpg")
            XCTAssertEqual(movie.backdropPath, "/backdrop.jpg")
        } catch {
            XCTFail("Should decode Movie model: \(error)")
        }
    }

    func testDecodingErrorForInvalidJSON() async {
        // Given
        let mockSession = URLSessionMock()
        let apiClient = APIClient(session: mockSession)

        let invalidJSON = "{ invalid json }"

        mockSession.data = invalidJSON.data(using: .utf8)!
        mockSession.response = HTTPURLResponse(
            url: URL(string: AppConfig.backendBaseURL + "/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When/Then
        do {
            let _: User = try await apiClient.get(endpoint: "/test", headers: nil)
            XCTFail("Should throw decoding error for invalid JSON")
        } catch let error as NetworkError {
            if case .decodingError = error {
                // Expected
            } else {
                XCTFail("Expected decodingError, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError.decodingError, got \(error)")
        }
    }

    // MARK: - HTTP Status Code Tests

    func testHandles401Unauthorized() async {
        // Given
        let mockSession = URLSessionMock()
        let apiClient = APIClient(session: mockSession)

        mockSession.data = Data()
        mockSession.response = HTTPURLResponse(
            url: URL(string: AppConfig.backendBaseURL + "/test")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )

        // When/Then
        do {
            let _: User = try await apiClient.get(endpoint: "/test", headers: nil)
            XCTFail("Should throw unauthorized error")
        } catch let error as NetworkError {
            if case .unauthorized = error {
                // Expected
            } else {
                XCTFail("Expected unauthorized error, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError.unauthorized, got \(error)")
        }
    }

    func testHandlesServerError() async {
        // Given
        let mockSession = URLSessionMock()
        let apiClient = APIClient(session: mockSession)

        mockSession.data = "Server error message".data(using: .utf8)!
        mockSession.response = HTTPURLResponse(
            url: URL(string: AppConfig.backendBaseURL + "/test")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )

        // When/Then
        do {
            let _: User = try await apiClient.get(endpoint: "/test", headers: nil)
            XCTFail("Should throw server error")
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Expected serverError, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError.serverError, got \(error)")
        }
    }

    func testHandlesConnectionError() async {
        // Given
        let mockSession = URLSessionMock()
        let apiClient = APIClient(session: mockSession)

        mockSession.error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)

        // When/Then
        do {
            let _: User = try await apiClient.get(endpoint: "/test", headers: nil)
            XCTFail("Should throw connection error")
        } catch let error as NetworkError {
            if case .connectionError = error {
                // Expected
            } else {
                XCTFail("Expected connectionError, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError.connectionError, got \(error)")
        }
    }
}

// MARK: - URLSession Mock

class URLSessionMock: URLSession {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    var lastRequest: URLRequest?

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        super.init(configuration: configuration, delegate: nil, delegateQueue: nil)
    }

    override func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request

        if let error = error {
            throw error
        }

        guard let data = data, let response = response else {
            throw NetworkError.noData
        }

        return (data, response)
    }
}

class MockURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        // Not used since we override data(for:) directly
    }

    override func stopLoading() {
        // Not used since we override data(for:) directly
    }
}
