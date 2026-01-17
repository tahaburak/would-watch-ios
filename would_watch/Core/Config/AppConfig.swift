//
//  AppConfig.swift
//  would_watch
//
//  Created by Claude on 17/01/2026.
//

import Foundation

enum AppConfig {
    static let backendBaseURL: String = {
        #if DEBUG
        return "http://localhost:8080/api"
        #else
        return "https://your-production-api.com/api"
        #endif
    }()

    static let supabaseURL = "https://your-supabase-url.supabase.co"
    static let supabaseAnonKey = "your-supabase-anon-key"
}
