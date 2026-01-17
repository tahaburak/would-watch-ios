//
//  Room.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation

struct Room: Codable, Identifiable {
    let id: String
    let name: String
    let hostId: String
    let status: RoomStatus
    let createdAt: Date?
    let participants: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case hostId = "host_id"
        case status
        case createdAt = "created_at"
        case participants
    }
}

enum RoomStatus: String, Codable {
    case active
    case completed
    case cancelled
}

struct CreateRoomRequest: Codable {
    let name: String
    let participants: [String]
}

struct CreateRoomResponse: Codable {
    let room: Room
}
