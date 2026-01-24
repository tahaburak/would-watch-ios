//
//  User.swift
//  would_watch
//
//  Created by Claude on 17/01/2026.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case createdAt = "created_at"
    }

    // Custom init to handle Supabase auth response which includes many extra fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        // createdAt is optional - Supabase auth response always includes it
        createdAt = try? container.decode(Date.self, forKey: .createdAt)
    }

    // Standard init for testing/creation
    init(id: String, email: String, createdAt: Date? = nil) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }
}
