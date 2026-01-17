//
//  Vote.swift
//  would_watch
//
//  Created by Claude on 18/01/2026.
//

import Foundation

enum VoteType: String, Codable {
    case yes
    case no
    case maybe
}

struct VoteRequest: Codable {
    let mediaId: Int
    let vote: VoteType

    enum CodingKeys: String, CodingKey {
        case mediaId = "media_id"
        case vote
    }
}

struct VoteResponse: Codable {
    let success: Bool
    let isMatch: Bool?

    enum CodingKeys: String, CodingKey {
        case success
        case isMatch = "is_match"
    }
}

struct RoomMatch: Codable, Identifiable {
    let id: Int
    let movie: Movie
    let voters: [String]

    var voterId: Int { id } // For Identifiable conformance
}
