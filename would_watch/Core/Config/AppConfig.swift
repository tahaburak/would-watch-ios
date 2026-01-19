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
        // Check for custom URL first (highest priority - allows runtime override)
        if let custom = UserDefaults.standard.string(forKey: "custom_api_url"), !custom.isEmpty {
            return custom
        }

        // Check for environment variable (useful for testing/CI)
        if let envURL = ProcessInfo.processInfo.environment["API_BASE_URL"] {
            return envURL
        }
        
        // Check Info.plist for configuration
        if let infoPlistURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String {
            return infoPlistURL
        }
        
        // Default to production server (https://would.watch/api)
        // For local development, set API_BASE_URL environment variable or use custom URL in settings
        return "https://would.watch/api"
    }()

    static let supabaseURL = "https://gtjokreqhfsydfmtbtvg.supabase.co"
    static let supabaseAnonKey = "sb_publishable_G-_D63xGxZ9_GED4okXgoQ_pz-Kjn6E"
}
