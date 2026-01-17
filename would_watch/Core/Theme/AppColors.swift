//
//  AppColors.swift
//  would_watch
//
//  Created by Claude on 17/01/2026.
//

import SwiftUI

struct AppColors {
    static let primary = Color("Primary", bundle: nil)
    static let secondary = Color("Secondary", bundle: nil)
    static let background = Color("Background", bundle: nil)
    static let surface = Color("Surface", bundle: nil)
    static let error = Color.red
    static let onPrimary = Color.white
    static let onBackground = Color.primary
    static let onSurface = Color.primary

    // Fallback colors if custom colors are not defined
    static let primaryFallback = Color.blue
    static let secondaryFallback = Color.gray
    static let backgroundFallback = Color(UIColor.systemBackground)
    static let surfaceFallback = Color(UIColor.secondarySystemBackground)
}
