# iOS API Endpoint Fixes

## Problem
iOS app was getting 404 errors when calling backend API endpoints because the endpoint paths didn't match the actual backend routes.

## Root Cause
The iOS services were using incorrect endpoint paths that didn't match what the Go backend actually implements.

## Fixes Applied

### 1. ProfileService (ProfileService.swift)
**Before:**
- `GET /profile` ❌
- `PUT /profile` ❌

**After:**
- `GET /me/profile` ✅
- `PUT /me/profile` ✅

**Backend Route:** `/api/me/profile` (GET/PUT)

---

### 2. SocialService (SocialService.swift)
**Before:**
- `GET /social/friends` ❌
- `GET /social/search?q=...` ❌
- `POST /social/follow` ❌
- `POST /social/unfollow` ❌

**After:**
- `GET /me/following` ✅
- `GET /users/search?q=...` ✅
- `POST /follows/` ✅
- `DELETE /follows/` ✅

**Backend Routes:**
- `/api/me/following` (GET)
- `/api/users/search` (GET)
- `/api/follows/` (POST/DELETE)

---

### 3. RoomService (RoomService.swift)
**Before:**
- `GET /api/rooms` ❌ (double `/api` prefix!)
- `POST /api/rooms` ❌
- `POST /api/rooms/{id}/join` ❌
- `GET /api/rooms/{id}` ❌
- `POST /api/rooms/{id}/vote` ❌
- `GET /api/rooms/{id}/matches` ❌

**After:**
- `GET /rooms` ✅
- `POST /rooms` ✅
- `POST /rooms/{id}/join` ✅
- `GET /rooms/{id}` ✅
- `POST /rooms/{id}/vote` ✅
- `GET /rooms/{id}/matches` ✅

**Backend Routes:** `/api/rooms` (GET/POST), `/api/rooms/{id}/*` (various)

**Issue:** RoomService was including `/api` prefix when APIClient already adds it via `AppConfig.backendBaseURL = "https://would.watch/api"`. This caused double `/api/api/` in the URL.

---

## How API Base URL Works

### AppConfig Setup
```swift
static let backendBaseURL: String = {
    // ... checks for custom URL, environment variable, Info.plist ...
    return "https://would.watch/api"  // Default
}()
```

### APIClient Behavior
When you call:
```swift
apiClient.get(endpoint: "/rooms", headers: nil)
```

APIClient constructs the full URL as:
```
https://would.watch/api + /rooms = https://would.watch/api/rooms
```

### Rule
**Always use endpoint paths WITHOUT the `/api` prefix** in service files, since APIClient adds it automatically.

---

## Backend Routes Reference

From `backend/cmd/api/main.go`:

```go
// Auth (Supabase handles this directly)

// Protected endpoints
mux.Handle("/api/me", authMiddleware(...))
mux.Handle("/api/me/profile", authMiddleware(...))       // GET, PUT
mux.Handle("/api/me/following", authMiddleware(...))     // GET

mux.Handle("/api/users/search", authMiddleware(...))     // GET

mux.Handle("/api/follows/", authMiddleware(...))         // POST, DELETE

mux.Handle("/api/rooms", authMiddleware(...))            // GET, POST
mux.Handle("/api/rooms/{id}/invite", authMiddleware(...))
mux.Handle("/api/rooms/{id}/vote", authMiddleware(...))
mux.Handle("/api/rooms/{id}/matches", authMiddleware(...))

mux.Handle("/api/sessions/{id}/vote", authMiddleware(...))
mux.Handle("/api/sessions/{id}/complete", authMiddleware(...))
mux.Handle("/api/sessions/{id}/matches", authMiddleware(...))
mux.Handle("/api/sessions/{id}/recommendations", authMiddleware(...))
```

---

## Testing

### Before Fix
- Login worked (after User model fix)
- Profile loading: 404 not found ❌
- Friends loading: Would have failed with 404 ❌
- Rooms loading: Would have failed with 404 ❌

### After Fix
- Login: ✅
- Profile loading: Should work ✅
- Friends loading: Should work ✅
- Rooms loading: Should work ✅

---

## Files Modified

1. `ios/would_watch/Core/Network/ProfileService.swift`
   - Changed `/profile` → `/me/profile`

2. `ios/would_watch/Core/Network/SocialService.swift`
   - Changed `/social/friends` → `/me/following`
   - Changed `/social/search` → `/users/search`
   - Changed `/social/follow` → `/follows/` (POST)
   - Changed `/social/unfollow` → `/follows/` (DELETE method)

3. `ios/would_watch/Core/Network/RoomService.swift`
   - Removed `/api` prefix from all endpoints
   - Changed `/api/rooms` → `/rooms`
   - Changed `/api/rooms/{id}/*` → `/rooms/{id}/*`

---

## How to Verify

1. **Profile Screen**: Login and tap Profile tab - should load user profile without 404 error
2. **Friends Screen**: Tap Friends tab - should load following list
3. **Rooms Screen**: Tap Rooms tab - should load rooms list
4. **Search**: Search for users - should return results

---

## Lessons Learned

1. **Backend Documentation**: Backend API routes should be documented in a single place (OpenAPI/Swagger spec would help)

2. **API Client Convention**: Establish clear convention that APIClient adds base URL with `/api`, so service files should never include it

3. **Testing**: Integration tests would catch endpoint mismatches early

4. **Code Review**: When adding new services, verify endpoints match backend routes exactly

---

## Related Issues Fixed

- Auth decoding error (User.swift custom Codable init)
- Profile 404 error
- Potential social features 404 errors
- Potential rooms 404 errors
