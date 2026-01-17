# Push Notifications Setup Guide

## Prerequisites

1. **Apple Developer Account** (Paid membership required)
2. **App ID** with Push Notifications capability enabled
3. **APNs Authentication Key** or Certificate

## Xcode Configuration

### 1. Enable Push Notifications Capability

1. Open `would_watch.xcodeproj` in Xcode
2. Select the `would_watch` target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Add "Push Notifications"

### 2. Background Modes (Optional)

For background notification handling:
1. Add "Background Modes" capability
2. Enable:
   - ☑️ Remote notifications
   - ☑️ Background fetch

## Apple Developer Portal Setup

### 1. Create APNs Authentication Key

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to Certificates, Identifiers & Profiles
3. Go to Keys
4. Click "+" to create a new key
5. Name: "Would Watch APNs Key"
6. Enable: ☑️ Apple Push Notifications service (APNs)
7. Click Continue → Register → Download

**Important:** Save the `.p8` file and note the Key ID and Team ID

### 2. Configure App ID

1. Go to Identifiers
2. Select your App ID (`com.burak.wouldwatch`)
3. Ensure "Push Notifications" is enabled
4. If needed, click "Edit" and enable it
5. Save changes

## Backend Integration

### 1. Store Device Tokens

Create endpoint to receive device tokens:

```swift
// Backend endpoint
POST /api/devices/register
{
  "token": "device_token_here",
  "platform": "ios",
  "user_id": "user_id_here"
}
```

### 2. Send Push Notifications

Using APNs HTTP/2 API:

```bash
curl -v \
  -H "apns-topic: com.burak.wouldwatch" \
  -H "apns-push-type: alert" \
  -H "authorization: bearer $JWT_TOKEN" \
  --http2 \
  --data '{"aps":{"alert":{"title":"Room Invite","body":"Join movie night!"},"sound":"default"},"room_id":"abc123","type":"room_invite"}' \
  https://api.push.apple.com/3/device/$DEVICE_TOKEN
```

## Notification Payloads

### Room Invite
```json
{
  "aps": {
    "alert": {
      "title": "Room Invite",
      "body": "John invited you to 'Friday Movie Night'"
    },
    "sound": "default",
    "badge": 1
  },
  "type": "room_invite",
  "room_id": "abc123"
}
```

### Match Found
```json
{
  "aps": {
    "alert": {
      "title": "It's a Match!",
      "body": "You matched on 'Inception'"
    },
    "sound": "default"
  },
  "type": "match_found",
  "room_id": "abc123",
  "movie_id": 27205
}
```

### Participant Joined
```json
{
  "aps": {
    "alert": {
      "title": "Sarah joined",
      "body": "Sarah joined your room"
    },
    "sound": "default"
  },
  "type": "participant_joined",
  "room_id": "abc123"
}
```

## Testing Push Notifications

### Using Xcode Simulator (iOS 16+)

1. Drag a `.apns` file to the simulator
2. Or use command line:

```bash
xcrun simctl push booted com.burak.wouldwatch notification.apns
```

Example `notification.apns`:
```json
{
  "Simulator Target Bundle": "com.burak.wouldwatch",
  "aps": {
    "alert": {
      "title": "Test Notification",
      "body": "This is a test"
    },
    "sound": "default"
  },
  "type": "room_invite",
  "room_id": "test123"
}
```

### Using Physical Device

1. Build and run app on device
2. Allow notifications when prompted
3. Copy device token from console
4. Use a tool like [Pusher](https://github.com/noodlewerk/NWPusher) or curl to send test notification

## Request Permission

The app requests permission after login:

```swift
Task {
    let granted = await pushNotificationService.requestAuthorization()
    if granted {
        print("Push notifications authorized")
    }
}
```

## Handling Notifications

### Foreground
Notifications appear as banner even when app is open.

### Background/Killed
Tapping notification opens app and navigates to room via deep link.

### Silent Notifications
For background updates without alerting user:

```json
{
  "aps": {
    "content-available": 1
  },
  "type": "participant_joined",
  "room_id": "abc123"
}
```

## Debugging

### Check Registration
```swift
// In app
print("Device token: \(pushNotificationService.deviceToken)")
print("Authorized: \(pushNotificationService.isAuthorized)")
```

### Enable Logging
Add to Xcode scheme → Run → Arguments:
```
-APSEnvironment development
```

### Common Issues

1. **No device token received**
   - Check internet connection
   - Verify Push Notifications capability is enabled
   - Check provisioning profile includes push

2. **Notifications not appearing**
   - Check notification settings in iOS Settings app
   - Verify payload format
   - Check APNs certificate/key validity

3. **Wrong environment**
   - Development builds use sandbox APNs
   - Production builds use production APNs
   - Use correct endpoint for testing

## Production Checklist

- [ ] Push Notifications capability enabled
- [ ] APNs key created and stored securely
- [ ] Backend configured to send push notifications
- [ ] Device tokens stored in database
- [ ] Payload formats tested
- [ ] Deep links work from notifications
- [ ] Notification permissions requested appropriately
- [ ] Analytics tracking notification opens
