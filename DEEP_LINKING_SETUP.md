# Deep Linking Setup Guide

## URL Scheme Setup

1. Open `would_watch.xcodeproj` in Xcode
2. Select the `would_watch` target
3. Go to the "Info" tab
4. Expand "URL Types"
5. Click "+" to add a new URL type
6. Configure:
   - **Identifier**: `com.burak.wouldwatch`
   - **URL Schemes**: `wouldwatch`
   - **Role**: Editor

## Universal Links Setup

### 1. Enable Associated Domains

1. Select the `would_watch` target in Xcode
2. Go to "Signing & Capabilities" tab
3. Click "+ Capability"
4. Add "Associated Domains"
5. Add the following domains:
   - `applinks:wouldwatch.app`
   - `applinks:www.wouldwatch.app`

### 2. Create Apple App Site Association File

Create a file named `apple-app-site-association` (no extension) on your web server at:
- `https://wouldwatch.app/.well-known/apple-app-site-association`
- `https://wouldwatch.app/apple-app-site-association`

Content:
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.burak.wouldwatch",
        "paths": [
          "/join/*",
          "/room/*",
          "/profile/*"
        ]
      }
    ]
  }
}
```

Replace `TEAM_ID` with your Apple Developer Team ID.

### 3. Serve the File

Ensure the file is served:
- Content-Type: `application/json`
- HTTPS only
- No redirects
- Accessible without authentication

## Testing Deep Links

### URL Scheme (wouldwatch://)
```bash
# Test in Simulator
xcrun simctl openurl booted "wouldwatch://room/test-room-123"

# Test room link
wouldwatch://room/abc123

# Test profile link
wouldwatch://profile/user456
```

### Universal Links (https://)
```bash
# Test in Simulator
xcrun simctl openurl booted "https://wouldwatch.app/join/test-room-123"

# Test in Safari
https://wouldwatch.app/join/abc123
https://wouldwatch.app/room/abc123
```

## Supported Deep Link Patterns

### Room Links
- `wouldwatch://room/{roomId}`
- `https://wouldwatch.app/join/{roomId}`
- `https://wouldwatch.app/room/{roomId}`

### Profile Links
- `wouldwatch://profile/{userId}`
- `https://wouldwatch.app/profile/{userId}`
- `https://wouldwatch.app/user/{userId}`

## Behavior

### When Not Authenticated
- Deep link is stored
- User is shown login screen
- After successful login, user is automatically redirected to the deep linked content

### When Authenticated
- User is immediately navigated to the deep linked content
- Room lobby opens as a modal sheet
- Profile opens in navigation stack

## Debugging

Enable deep link debugging in Xcode:
1. Edit Scheme → Run → Arguments
2. Add environment variable: `_UIApplicationLaunchOptionsURLKey` = `your-test-url`

Check console logs for deep link parsing:
```swift
print("Deep link received: \(url)")
print("Parsed as: \(DeepLink.parse(from: url))")
```
