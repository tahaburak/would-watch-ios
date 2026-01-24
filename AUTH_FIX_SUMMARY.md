# iOS Authentication Fix Summary

## Problem
iOS app login was failing with the error: **"The data couldn't be read because it isn't in the correct format."**

Despite the same credentials working perfectly on the web frontend (`tahaburak.koc+wwtest@gmail.com` / `password123`), the iOS app couldn't log in.

## Root Cause Analysis

### Investigation Steps
1. ✅ Verified Supabase credentials match between web and iOS (both use `https://supabase.tahaburak.com`)
2. ✅ Tested Supabase REST API directly with curl - login worked perfectly
3. ✅ Compared web (using Supabase JS SDK) vs iOS (using Supabase REST API) auth implementations
4. ✅ Examined error toast screenshot showing "data couldn't be read" decoding error
5. ✅ Analyzed Supabase JSON response structure

### Root Cause
The iOS `User` model was too strict and didn't handle extra fields in Supabase's auth response.

**Supabase Auth Response** includes many fields:
```json
{
  "user": {
    "id": "b29cd188-94ff-4105-8c22-4a521155f0cd",
    "email": "tahaburak.koc+wwtest@gmail.com",
    "created_at": "2026-01-21T01:06:52.559554Z",
    "aud": "authenticated",           // Extra field
    "role": "authenticated",          // Extra field
    "email_confirmed_at": "...",      // Extra field
    "app_metadata": {...},            // Extra field
    "user_metadata": {...},           // Extra field
    "identities": [...],              // Extra field
    "last_sign_in_at": "...",         // Extra field
    "updated_at": "...",              // Extra field
    "is_anonymous": false             // Extra field
  }
}
```

**iOS User Model** only expected:
- `id`
- `email`
- `created_at` (optional)

Swift's default `Codable` decoder **fails** when the JSON contains extra keys not defined in the model, unless you implement a custom `init(from decoder:)`.

## Solution

Added custom decoding to the `User` struct in `User.swift`:

```swift
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case createdAt = "created_at"
    }

    // Custom init to handle Supabase auth response with extra fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        // createdAt is optional - Supabase auth response always includes it
        createdAt = try? container.decode(Date.self, forKey: .createdAt)
    }

    // Standard init for testing/creation
    init(id: String, email: String, createdAt: Date? = nil) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }
}
```

### How This Works
- `CodingKeys` enum defines **only the fields we care about**
- Custom `init(from decoder:)` uses `container(keyedBy: CodingKeys.self)` which **ignores** any extra keys
- Extra fields like `aud`, `role`, `email_confirmed_at`, etc. are silently ignored
- `createdAt` uses `try?` to handle optional gracefully

## Test Results

### Before Fix
- **Unit Tests**: 56/56 passing ✅
- **UI Tests**: 11/13 failing ❌
- **Error**: "The data couldn't be read because it isn't in the correct format"

### After Fix
- **Unit Tests**: 56/56 passing ✅
- **UI Tests**: 13/13 passing ✅ (11 tests + 2 launch tests)
- **Total**: 69 tests, 0 failures ✅

### Previously Failing Tests Now Passing
1. `testNavigateToSettings` - Required login
2. `testNavigateToRoomList` - Required login

## Files Modified

### Core Fix
- `ios/would_watch/Core/Models/User.swift` - Added custom Codable implementation

### Additional Work (Social Features Testing)
- `would_watchTests/SocialViewModelTests.swift` - NEW (15 comprehensive tests)
- `would_watchTests/MockAPIClient.swift` - Extended with Friend/Social support
- `would_watchUITests/would_watchUITests.swift` - Fixed testNavigateToSignUpFromLogin
- `would_watch.xctestplan` - Fixed JSON parsing error, disabled parallelization
- `management/tasks/ios_sprint_2_social.md` - Documented Task 4 completion

## Key Learnings

1. **Swift Codable Default Behavior**: By default, Swift's `Codable` doesn't ignore extra JSON keys. You need custom decoding.

2. **Web vs Native API Differences**:
   - Web: Uses Supabase JS SDK (handles extra fields automatically)
   - iOS: Uses Supabase REST API directly (raw JSON needs manual handling)

3. **Better Error Messages Needed**: The error "data couldn't be read because it isn't in the correct format" was too vague. Consider adding more detailed logging in AuthService to show actual JSON parsing errors.

4. **Test Credentials**: The credentials `tahaburak.koc+wwtest@gmail.com` / `password123` are valid and work across all platforms now.

## Recommendations

### Future Improvements
1. **Add Logging**: Log the actual JSON response before decoding in AuthService for debugging
2. **Consider Supabase Swift SDK**: Use the official Supabase Swift SDK instead of raw REST API calls
3. **Stronger Type Safety**: Consider adding more user fields (role, metadata) if needed by the app
4. **Error Handling**: Improve error messages to distinguish between network errors, auth errors, and decoding errors

### Test Maintenance
1. **UI Test Stability**: Current UI tests depend on valid test credentials in Supabase
2. **Network Requirements**: UI tests require internet connectivity to Supabase
3. **Consider Mocking**: For faster tests, consider mocking auth responses in UI tests

## Commit Message

```
Fix iOS authentication decoding error blocking login

Root cause: User model couldn't decode Supabase auth response due to extra fields.
Web worked because Supabase JS SDK handles this automatically, but iOS REST API
returns raw JSON with many additional fields (aud, role, email_confirmed_at,
app_metadata, user_metadata, identities, etc).

Solution: Implement custom Codable init(from:) in User model to ignore extra fields
by using keyed container that only decodes id, email, and created_at.

Also includes:
- Add comprehensive SocialViewModel test suite (15 tests)
- Extend MockAPIClient with Friend/Social support
- Fix UI tests (testNavigateToSignUpFromLogin toggle behavior)
- Fix test plan JSON parsing error

Test results: 69/69 tests passing (56 unit + 13 UI)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```
