# Agent Guide: iOS Repository

## 🧠 Context
This is the **Native Mobile App** for iOS, built with SwiftUI using the MVVM pattern.

## 🏗 Structure
- **`would_watch/`**: Main App Bundle.
  - **`Core/`**: App Lifecycle, Config (`AppConfig.swift`), DI Container.
  - **`Features/`**: Feature modules (Auth, Room, Movie).
    - Each feature has `Views/`, `ViewModels/`, `Models/`.
  - **`Services/`**: API Networking, Supabase Client.
  - **`UI/`**: Shared Design System (Components, Colors).

## 🔑 Key Facts for Agents
1.  **Dependencies**: Swift Package Manager (SPM).
2.  **Supabase**: Uses `Supabase` Swift SDK for Auth and Realtime.
3.  **Config**: `AppConfig.swift` holds URLs/Keys.
4.  **Testing**: XCTest for Units, XCUITest for UI.

## 🛠 Common Tasks
- **Build**: `xcodebuild -scheme would_watch`
- **Test**: `xcodebuild test -scheme would_watch`
