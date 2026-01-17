# Would Watch - iOS App

SwiftUI application for Would Watch - A movie recommendation and group watch app that helps users decide what to watch next, either individually or with friends.

## Features
- 🔐 User Authentication (Login/Signup)
- 👥 Social Features (Friends & Search)
- 👤 User Profile & Privacy Settings
- 🏠 Room Creation & Management
- 🎬 Movie Recommendations (upcoming)
- 🗳️ Group Voting Sessions (upcoming)
- 🎯 Real-time Match Updates (upcoming)

## Tech Stack
- **Language**: Swift 5+
- **Framework**: SwiftUI
- **Minimum iOS**: 17.0
- **Architecture**: MVVM
- **Networking**: URLSession with async/await
- **Backend**: Go REST API + Supabase

## Project Structure
```
would_watch/
├── App/                    # App entry point
├── Features/               # Feature modules
│   ├── Auth/              # Authentication
│   ├── Social/            # Friends & search
│   ├── Profile/           # User profile & settings
│   ├── Room/              # Room creation & management
│   ├── Vote/              # Voting feature (upcoming)
│   └── Dashboard/         # Main tab navigation
└── Core/                   # Core functionality
    ├── Network/           # API client & services
    ├── Models/            # Data models
    ├── Theme/             # App colors & fonts
    └── Config/            # App configuration
```

## Setup
1. Open `would_watch.xcodeproj` in Xcode
2. Update `AppConfig.swift` with your backend URL
3. Build and run (⌘R)

## API Configuration
The app connects to the Would Watch backend. Update the base URL in `Core/Config/AppConfig.swift`:
```swift
static let backendBaseURL = "https://your-api-url.com/api"
```

## Development Status

✅ **Sprint 1 Completed:**
- Project structure with MVVM architecture
- Network layer with APIClient
- Authentication views and flows

✅ **Sprint 2 Completed (Social Native):**
- Friends list with follow/unfollow functionality
- User search with debounced API calls
- Profile view with avatar and stats
- Privacy settings (Everyone/Friends/Private)
- Room creation with friend picker
- Rooms list view with status indicators
- Main tab navigation (Rooms/Friends/Profile)

## Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
