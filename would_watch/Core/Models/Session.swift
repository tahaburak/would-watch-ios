//
//  Session.swift
//  would_watch
//
//  Created by Claude on 17/01/2026.
//

import Foundation

struct Session: Codable, Identifiable {
    let id: String
    let hostId: String
    let status: SessionStatus
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case hostId = "host_id"
        case status
        case createdAt = "created_at"
    }
}

enum SessionStatus: String, Codable {
    case active
    case completed
    case cancelled
}
