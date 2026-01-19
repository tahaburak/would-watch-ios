//
//  NetworkError.swift
//  would_watch
//
//  Created by Claude on 17/01/2026.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case unauthorized
    case connectionError(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message ?? "Unknown error")"
        case .unauthorized:
            return "Invalid email or password"
        case .connectionError(let error):
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorCannotFindHost, NSURLErrorDNSLookupFailed:
                    return "Cannot connect to server. Please check:\n• Backend server is running\n• Correct API URL in configuration\n• Network connection"
                case NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost:
                    return "Cannot connect to server. The server may be down or unreachable."
                case NSURLErrorTimedOut:
                    return "Connection timed out. The server may be slow or unreachable."
                default:
                    return "Connection error: \(error.localizedDescription)"
                }
            }
            return "Connection error: \(error.localizedDescription)"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}
