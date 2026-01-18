//
//  RoomViewModel.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class RoomViewModel: ObservableObject {
    @Published var rooms: [Room] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let roomService: RoomServiceProtocol

    init(roomService: RoomServiceProtocol = RoomService()) {
        self.roomService = roomService
    }

    func loadRooms() async {
        isLoading = true
        errorMessage = nil

        do {
            rooms = try await roomService.getRooms()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createRoom(name: String, participants: [String]) async -> Bool {
        guard !name.isEmpty else {
            errorMessage = "Room name cannot be empty"
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            let newRoom = try await roomService.createRoom(name: name, participants: participants)
            rooms.insert(newRoom, at: 0)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }

        isLoading = false
    }

    func joinRoom(_ roomId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await roomService.joinRoom(roomId: roomId)
            await loadRooms()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func submitVote(roomId: String, mediaId: Int, vote: VoteType) async throws -> VoteResponse {
        return try await roomService.submitVote(roomId: roomId, mediaId: mediaId, vote: vote)
    }

    func getMatches(roomId: String) async throws -> [RoomMatch] {
        return try await roomService.getMatches(roomId: roomId)
    }
}
