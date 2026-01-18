# Platform Compatibility Guide

This document outlines all platform-specific APIs used in the iOS project and how they should be handled for cross-platform compatibility (iOS/macOS).

## ✅ Fixed Issues Summary

All platform-specific APIs have been properly wrapped in conditional compilation. This document serves as a reference to prevent regressions.

## Platform-Specific APIs

### 1. UIKit Types (iOS/iPadOS only)

**APIs:**
- `UIColor` - System colors
- `UIApplication` - App lifecycle
- `UIView` - View hierarchy (rarely used in SwiftUI)

**Pattern:**
```swift
#if canImport(UIKit)
import UIKit
#endif

// Usage in computed properties:
private var backgroundColor: Color {
    #if canImport(UIKit)
    return Color(UIColor.systemGray6)
    #else
    return Color.gray.opacity(0.1)
    #endif
}
```

**❌ WRONG:**
```swift
.background(Color(UIColor.systemGray6))  // Direct usage in modifier
```

**✅ CORRECT:**
```swift
.background(backgroundColor)  // Use computed property
```

### 2. Navigation Bar Modifiers (iOS only)

**APIs:**
- `.navigationBarTitleDisplayMode(.inline)`
- `.navigationBarHidden(true)`
- `ToolbarItem(placement: .navigationBarLeading)`
- `ToolbarItem(placement: .navigationBarTrailing)`

**Pattern:**
```swift
#if os(iOS)
.navigationBarTitleDisplayMode(.inline)
#endif

.toolbar {
    #if os(iOS)
    ToolbarItem(placement: .navigationBarTrailing) {
        // iOS-specific toolbar item
    }
    #else
    ToolbarItem(placement: .automatic) {
        // macOS fallback
    }
    #endif
}
```

### 3. Text Input Modifiers (iOS only)

**APIs:**
- `.textInputAutocapitalization(.never)` / `.words`
- `.keyboardType(.emailAddress)`
- `.textContentType(.emailAddress)`

**Pattern:**
```swift
TextField("Email", text: $email)
    #if os(iOS)
    .textInputAutocapitalization(.never)
    .keyboardType(.emailAddress)
    #endif
    .textContentType(TextContentType.emailAddress)
```

### 4. Color System Colors

**All UIColor usages must be in computed properties:**

**Files with computed color properties:**
- `VotingView.swift` - `movieInfoBackgroundColor`, `movieCardBackgroundColor`, `matchOverlayBackgroundColor`
- `RealtimeLobbyView.swift` - `participantCountBackgroundColor`, `shareButtonBackgroundColor`, `matchNotificationBackgroundColor`, `participantOverlayBackgroundColor`
- `MatchesView.swift` - `voterBadgeBackgroundColor`, `shareButtonBackgroundColor`, `matchCardBackgroundColor`
- `RoomLobbyView.swift` - `shareButtonBackgroundColor`
- `UserSearchView.swift` - `searchBarBackgroundColor`
- `MovieSearchView.swift` - `searchBarBackgroundColor`
- `ProfileView.swift` - `statBackgroundColor`
- `AppColors.swift` - Already properly conditionalized

## Common Patterns

### Pattern 1: Background Colors
```swift
// ✅ CORRECT
private var myBackgroundColor: Color {
    #if canImport(UIKit)
    return Color(UIColor.systemGray6)
    #else
    return Color.gray.opacity(0.1)
    #endif
}

// Usage
.background(myBackgroundColor)
```

### Pattern 2: Toolbar Items
```swift
// ✅ CORRECT
.toolbar {
    #if os(iOS)
    ToolbarItem(placement: .navigationBarTrailing) {
        Button("Action") { }
    }
    #else
    ToolbarItem(placement: .automatic) {
        Button("Action") { }
    }
    #endif
}
```

### Pattern 3: Navigation Modifiers
```swift
// ✅ CORRECT
.navigationTitle("Title")
#if os(iOS)
.navigationBarTitleDisplayMode(.inline)
.navigationBarHidden(true)
#endif
```

## Verification Checklist

Before committing, ensure:
- [ ] No direct `Color(UIColor.*)` usage in modifier chains
- [ ] All `UIColor` usages are in computed properties
- [ ] All `.navigationBar*` modifiers are wrapped in `#if os(iOS)`
- [ ] All `.textInputAutocapitalization` are wrapped in `#if os(iOS)`
- [ ] All `ToolbarItem` with `.navigationBar*` placement have macOS fallbacks
- [ ] Run `./check-build-issues.sh` to verify

## Quick Fix Script

If you add a new UIColor usage, use this pattern:

```swift
// 1. Add computed property at bottom of struct/class
private var myColor: Color {
    #if canImport(UIKit)
    return Color(UIColor.systemGray6)
    #else
    return Color.gray.opacity(0.1)
    #endif
}

// 2. Use in modifier
.background(myColor)
```

## Files Already Fixed

All these files have been properly fixed:
- ✅ VotingView.swift
- ✅ RealtimeLobbyView.swift
- ✅ MatchesView.swift
- ✅ RoomLobbyView.swift
- ✅ UserSearchView.swift
- ✅ MovieSearchView.swift
- ✅ ProfileView.swift
- ✅ LoginView.swift
- ✅ CreateRoomSheet.swift
- ✅ SettingsSheet.swift
- ✅ FriendsListView.swift
- ✅ ProfileView.swift
- ✅ AppColors.swift
