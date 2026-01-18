# Network Configuration Guide

This guide explains how to configure the API connection for the iOS app.

## Quick Fix for "Cannot connect to server" Error

The error "A server with the specified hostname could not be found" means the app cannot reach the backend server. Here's how to fix it:

### Option 1: Start the Backend Server

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Make sure you have Go installed and dependencies:
   ```bash
   go mod download
   ```

3. Set up environment variables (create a `.env` file or export them):
   ```bash
   export TMDB_API_KEY=your_key
   export SUPABASE_URL=your_url
   export SUPABASE_ANON_KEY=your_key
   export SUPABASE_JWT_SECRET=your_secret
   export DATABASE_URL=your_db_url
   export PORT=8080
   ```

4. Start the server:
   ```bash
   go run cmd/api/main.go
   ```

   You should see: `Server listening on :8080`

### Option 2: Configure Custom API URL

If your backend is running on a different host/port, you can configure it:

#### Method A: Environment Variable (Recommended for Testing)

1. In Xcode, go to **Product → Scheme → Edit Scheme...**
2. Select **Run** → **Arguments**
3. Add an environment variable:
   - Name: `API_BASE_URL`
   - Value: `http://your-host:8080/api` (e.g., `http://192.168.1.100:8080/api` for a device on your network)

#### Method B: Info.plist (For Permanent Configuration)

1. Open `would_watch/Info.plist` (or create it if it doesn't exist)
2. Add a new entry:
   - Key: `API_BASE_URL`
   - Type: `String`
   - Value: `http://your-host:8080/api`

#### Method C: Edit AppConfig.swift Directly

Edit `ios/would_watch/Core/Config/AppConfig.swift` and change the URL in the `backendBaseURL` computed property.

## Platform-Specific Notes

### iOS Simulator
- Uses `127.0.0.1:8080` by default (automatically configured)
- If `localhost` doesn't work, the app will try `127.0.0.1`

### macOS App
- Uses `localhost:8080` by default
- Should work if backend is running on the same machine

### Physical iOS Device
- **Cannot use `localhost`** - it refers to the device itself, not your computer
- Use your computer's IP address instead:
  1. Find your Mac's IP: `ifconfig | grep "inet " | grep -v 127.0.0.1`
  2. Configure `API_BASE_URL` to `http://YOUR_IP:8080/api` (e.g., `http://192.168.1.100:8080/api`)
  3. Make sure your Mac's firewall allows connections on port 8080

## Testing the Connection

### Check if Backend is Running

```bash
curl http://localhost:8080/health
```

Should return: `OK`

### Test from iOS App

1. The app will show improved error messages if connection fails
2. Check Xcode console for detailed error logs
3. Verify the API URL in logs (search for "API_BASE_URL" or check AppConfig)

## Common Issues

### "Cannot find host" Error

**Cause:** Backend server is not running or URL is incorrect.

**Solution:**
1. Verify backend is running: `curl http://localhost:8080/health`
2. Check the configured URL matches where the server is running
3. For physical devices, use IP address instead of `localhost`

### "Connection timed out" Error

**Cause:** Server is running but unreachable (firewall, wrong port, etc.)

**Solution:**
1. Check backend is listening on the correct port
2. Verify firewall settings allow connections
3. For physical devices, ensure device and computer are on the same network

### "Unauthorized" Error

**Cause:** Backend is reachable but authentication failed.

**Solution:**
1. This is expected if credentials are wrong
2. Check backend logs for authentication errors
3. Verify user exists in database

## Production Configuration

For production builds, update `AppConfig.swift`:

```swift
#else
return "https://your-production-api.com/api"
#endif
```

Replace `your-production-api.com` with your actual production server URL.

## Debugging Tips

1. **Check the actual URL being used:**
   Add this to `AppConfig.swift` temporarily:
   ```swift
   print("🔗 Using API URL: \(backendBaseURL)")
   ```

2. **Enable network logging:**
   The `APIClient` will now provide detailed error messages for connection issues.

3. **Test backend independently:**
   Use Postman or `curl` to verify backend endpoints work before testing in the app.

## Environment Variables Priority

The app checks for API URL in this order:
1. `API_BASE_URL` environment variable (highest priority)
2. `API_BASE_URL` in Info.plist
3. Default values in `AppConfig.swift` (lowest priority)
