# Adding SocialViewModelTests to Xcode Project

## Problem
The `SocialViewModelTests.swift` file exists but is not added to the Xcode project's test target, causing the error:
> "Tests cannot be run because the test plan 'would_watch' could not be read"

## Solution

Follow these steps to add the test file to your Xcode project:

### Option 1: Drag and Drop (Recommended)

1. Open `would_watch.xcodeproj` in Xcode
2. In the Project Navigator (left sidebar), locate the `would_watchTests` folder
3. In Finder, navigate to:
   ```
   /Users/burak/Documents/DEV/Projects/would_watch/ios/would_watchTests/
   ```
4. Drag `SocialViewModelTests.swift` from Finder into the `would_watchTests` group in Xcode
5. In the dialog that appears:
   - ✅ Check "Copy items if needed" (even though it's already there)
   - ✅ Check "would_watchTests" under "Add to targets"
   - Click "Finish"

### Option 2: Add Files to Project

1. Open `would_watch.xcodeproj` in Xcode
2. Right-click on the `would_watchTests` folder in Project Navigator
3. Select "Add Files to 'would_watch'..."
4. Navigate to the `would_watchTests` folder
5. Select `SocialViewModelTests.swift`
6. Ensure:
   - ✅ "Copy items if needed" is checked
   - ✅ "would_watchTests" is selected under targets
   - ⚪ "Create groups" is selected (not "Create folder references")
7. Click "Add"

### Option 3: Manual Build Phase Addition

If the file appears in the project but tests still don't run:

1. Select the `would_watch` project in Project Navigator
2. Select the `would_watchTests` target
3. Go to "Build Phases" tab
4. Expand "Compile Sources"
5. Click the "+" button
6. Find and add `SocialViewModelTests.swift`
7. Clean build folder: `Cmd+Shift+K`
8. Build: `Cmd+B`

## Verification

After adding the file, verify it's properly configured:

1. Select `SocialViewModelTests.swift` in Project Navigator
2. Open the File Inspector (right sidebar, first tab)
3. Under "Target Membership", ensure `would_watchTests` is checked

## Running the Tests

Once added:

1. Select an iOS Simulator (e.g., iPhone 15) from the device dropdown
2. Press `Cmd+U` to run all tests
3. Or click the diamond icon next to individual test methods

## Expected Result

You should see 15 new test cases under the `SocialViewModelTests` class:
- testLoadFriends_Success
- testLoadFriends_EmptyList
- testLoadFriends_NetworkError
- testLoadFriends_LoadingState
- testSearchUsers_Success
- testSearchUsers_EmptyQuery
- testSearchUsers_NetworkError
- testSearchUsers_ClearsResultsOnEmptyQuery
- testFollowUser_Success
- testFollowUser_UpdatesFriendsList
- testFollowUser_NetworkError
- testUnfollowUser_Success
- testUnfollowUser_UpdatesSearchResults
- testUnfollowUser_NetworkError
- testErrorMessage_ClearsOnSuccessfulLoad
- testErrorMessage_ClearsOnSuccessfulSearch

## Troubleshooting

### "Module 'would_watch' not found"
- Ensure the main app target builds successfully first
- Clean build folder (`Cmd+Shift+K`) and rebuild
- Check that `@testable import would_watch` is at the top of the file

### Tests not appearing
- Verify the file has the `.swift` extension
- Check Target Membership includes `would_watchTests`
- Restart Xcode if tests don't appear after adding

### Build errors
- Ensure all dependencies are properly linked
- Check that the test target's "Host Application" is set to `would_watch`
- Verify Swift version compatibility

## Alternative: Command Line Add

If you prefer to manually edit the project file:

```bash
cd /Users/burak/Documents/DEV/Projects/would_watch/ios
# Back up the project file first
cp would_watch.xcodeproj/project.pbxproj would_watch.xcodeproj/project.pbxproj.backup
# Then manually edit project.pbxproj to add the file reference
```

⚠️ **Warning:** Manually editing `.pbxproj` files can corrupt the project. Use Xcode's UI instead.
