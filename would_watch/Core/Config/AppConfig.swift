//
//  AppConfig.swift
//  would_watch
//
//  Created by Claude on 17/01/2026.
//

import Foundation

enum AppConfig {
    static var customBaseURL: String? {
        get {
            UserDefaults.standard.string(forKey: "custom_api_url")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "custom_api_url")
        }
    }

    static let backendBaseURL: String = {
        // Check for custom URL first
        if let custom = UserDefaults.standard.string(forKey: "custom_api_url"), !custom.isEmpty {
            return custom
        }

        // Check for environment variable first (useful for testing)
        if let envURL = ProcessInfo.processInfo.environment["API_BASE_URL"] {
            return envURL
        }
        
        // Check Info.plist for configuration
        if let infoPlistURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String {
            return infoPlistURL
        }
        
        #if DEBUG
        // For iOS Simulator, try 127.0.0.1 instead of localhost
        // For macOS, localhost should work
        #if os(iOS)
        return "http://127.0.0.1:8080/api"
        #else
        return "http://localhost:8080/api"
        #endif
        #else
        return "https://your-production-api.com/api"
        #endif
    }()

    static let supabaseURL = "https://your-supabase-url.supabase.co"
    static let supabaseAnonKey = "your-supabase-anon-key"
}
