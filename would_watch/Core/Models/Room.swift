//
//  Room.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation

struct Room: Codable, Identifiable {
    let id: String
    let name: String?
    let hostId: String
    let status: RoomStatus
    let createdAt: Date?
    let participants: [String]?
    let isPublic: Bool?
    
    // Backend uses creator_id, we map it to hostId
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case hostId = "creator_id"
        case status
        case createdAt = "created_at"
        case participants
        case isPublic = "is_public"
    }
    
    // Computed property to ensure name is never nil for UI
    var displayName: String {
        name ?? "Untitled Room"
    }
}

enum RoomStatus: String, Codable {
    case active
    case completed
    case cancelled
}

struct CreateRoomRequest: Codable {
    let name: String
    let isPublic: Bool
    let initialMembers: [String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case isPublic = "is_public"
        case initialMembers = "initial_members"
    }
}
