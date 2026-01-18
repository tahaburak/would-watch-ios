//
//  AppColors.swift
//  would_watch
//
//  Created by Claude on 17/01/2026.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

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
    #if canImport(UIKit)
    static let backgroundFallback = Color(UIColor.systemBackground)
    static let surfaceFallback = Color(UIColor.secondarySystemBackground)
    #else
    static let backgroundFallback = Color(white: 1.0)
    static let surfaceFallback = Color(white: 0.95)
    #endif
}
