//
//  RoomService.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation

protocol RoomServiceProtocol {
    func getRooms() async throws -> [Room]
    func createRoom(name: String, participants: [String]) async throws -> Room
    func joinRoom(roomId: String) async throws -> Room
}

final class RoomService: RoomServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    func getRooms() async throws -> [Room] {
        struct Response: Codable {
            let rooms: [Room]
        }
        let response: Response = try await apiClient.get(endpoint: "/rooms")
        return response.rooms
    }

    func createRoom(name: String, participants: [String]) async throws -> Room {
        let request = CreateRoomRequest(name: name, participants: participants)
        let response: CreateRoomResponse = try await apiClient.post(endpoint: "/rooms", body: request)
        return response.room
    }

    func joinRoom(roomId: String) async throws -> Room {
        return try await apiClient.post(endpoint: "/rooms/\(roomId)/join", body: EmptyBody())
    }
}

private struct EmptyBody: Codable {}
