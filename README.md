# Would Watch - iOS App

SwiftUI application for Would Watch - A movie recommendation and group watch app that helps users decide what to watch next, either individually or with friends.

## Features
- 🔐 User Authentication (Login/Signup)
- 👥 Social Features (Friends & Search)
- 👤 User Profile & Privacy Settings
- 🏠 Room Creation & Management
- 🎬 Movie Search & Display
- 🗳️ Swipe-based Voting on Movies
- 🎯 Match Display with Voter Info

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
│   ├── Room/              # Room lobby, voting & matches
│   ├── Movie/             # Movie search & display
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

✅ **Sprint 3 Completed (Voting & Room Interaction):**
- Movie search with TMDB integration
- Movie grid display with AsyncImage posters
- Room lobby with participants display
- Swipe-based voting interface (Tinder-style)
- Yes/No voting with drag gestures
- Match animations when votes align
- Matches view with voter information
- TMDB links and share functionality

## Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
