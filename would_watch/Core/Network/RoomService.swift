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
    func getRoom(roomId: String) async throws -> Room
    func submitVote(roomId: String, mediaId: Int, vote: VoteType) async throws -> VoteResponse
    func getMatches(roomId: String) async throws -> [RoomMatch]
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
        let response: Response = try await apiClient.get(endpoint: "/rooms", headers: nil)
        return response.rooms
    }

    func createRoom(name: String, participants: [String]) async throws -> Room {
        let request = CreateRoomRequest(name: name, participants: participants)
        let response: CreateRoomResponse = try await apiClient.post(endpoint: "/rooms", body: request, headers: nil)
        return response.room
    }

    func joinRoom(roomId: String) async throws -> Room {
        return try await apiClient.post(endpoint: "/rooms/\(roomId)/join", body: EmptyBody(), headers: nil)
    }

    func getRoom(roomId: String) async throws -> Room {
        return try await apiClient.get(endpoint: "/rooms/\(roomId)", headers: nil)
    }

    func submitVote(roomId: String, mediaId: Int, vote: VoteType) async throws -> VoteResponse {
        let request = VoteRequest(mediaId: mediaId, vote: vote)
        return try await apiClient.post(endpoint: "/rooms/\(roomId)/vote", body: request, headers: nil)
    }

    func getMatches(roomId: String) async throws -> [RoomMatch] {
        struct Response: Codable {
            let matches: [RoomMatch]
        }
        let response: Response = try await apiClient.get(endpoint: "/rooms/\(roomId)/matches", headers: nil)
        return response.matches
    }
}

private struct EmptyBody: Codable {}
