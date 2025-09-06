# Profile API Troubleshooting Guide

## Issue: Profile page can't call data from API

### ✅ What's Working
- Backend API is running and responding correctly
- Database is connected and has test data
- CORS headers are properly configured
- API returns valid JSON data

### 🔍 Common Issues & Solutions

#### 1. **Network Connectivity Issues**

**Problem**: Flutter app can't reach the backend API
**Solutions**:

##### For Android Emulator:
```dart
// In ProfileService, use:
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

##### For Physical Device:
```dart
// Find your computer's IP address and use:
static const String baseUrl = 'http://192.168.1.100:3000/api'; // Replace with your IP
```

##### For iOS Simulator:
```dart
// Use localhost:
static const String baseUrl = 'http://localhost:3000/api';
```

#### 2. **Backend Not Running**

**Check if backend is running**:
```bash
cd backend
npm run dev
```

**Expected output**: Server should start on port 3000

#### 3. **Database Not Connected**

**Start MySQL database**:
```bash
cd mysql(docker)
docker-compose up -d
```

**Run database migrations**:
```bash
cd backend
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed
```

#### 4. **CORS Issues**

**Check if CORS headers are present**:
```bash
curl -H "Origin: http://localhost" http://localhost:3000/api/profile?userId=1
```

**Expected headers**:
```
access-control-allow-origin: *
access-control-allow-methods: GET,POST,PUT,DELETE,OPTIONS
access-control-allow-headers: Content-Type, Authorization
```

#### 5. **Flutter Debugging**

**Enable debug logging** in ProfileService (already added):
```dart
print('ProfileService: Making request to $url');
print('ProfileService: Response status: ${response.statusCode}');
print('ProfileService: Response body: ${response.body}');
```

**Check Flutter console** for these debug messages when running the app.

### 🧪 Testing Steps

#### 1. Test API Directly
```bash
# Test with curl
curl "http://localhost:3000/api/profile?userId=1"

# Test with Node.js
node test-api.js
```

#### 2. Test from Flutter
1. Run the Flutter app
2. Navigate to Profile tab
3. Check console output for debug messages
4. Look for error messages in the UI

#### 3. Check Network Configuration

**For Android Emulator**:
- Use `10.0.2.2` instead of `localhost`
- Ensure backend is running on port 3000

**For Physical Device**:
- Find your computer's IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
- Use that IP instead of localhost
- Ensure both devices are on the same network

### 🔧 Quick Fixes

#### Fix 1: Update Base URL
```dart
// In lib/services/profile_service.dart
static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
// OR
static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000/api'; // Physical device
```

#### Fix 2: Check Backend Status
```bash
# Make sure backend is running
cd backend
npm run dev

# Check if port 3000 is in use
netstat -an | findstr :3000
```

#### Fix 3: Reset Database
```bash
cd backend
npm run prisma:migrate reset
npm run prisma:seed
```

### 📱 Platform-Specific Notes

#### Android Emulator
- Use `10.0.2.2` to access host machine
- Port forwarding is automatic

#### iOS Simulator
- Use `localhost` or `127.0.0.1`
- No special configuration needed

#### Physical Device
- Use your computer's actual IP address
- Both devices must be on same WiFi network
- Check firewall settings

### 🐛 Debug Information

When reporting issues, include:
1. Platform (Android/iOS, emulator/device)
2. Base URL being used
3. Console output from Flutter
4. Backend server logs
5. Network connectivity test results

### ✅ Verification Checklist

- [ ] Backend server is running (`npm run dev`)
- [ ] Database is running (`docker-compose up -d`)
- [ ] Database has data (`npm run prisma:seed`)
- [ ] API responds to curl test
- [ ] CORS headers are present
- [ ] Flutter app uses correct base URL
- [ ] Debug logging shows request/response
- [ ] No firewall blocking port 3000


