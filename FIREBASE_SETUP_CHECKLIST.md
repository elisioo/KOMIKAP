# Firebase Setup Checklist for KOMIKAP

## 🚀 Quick Start Checklist

### Phase 1: Firebase Console Setup (5-10 minutes)

- [ ] Go to [Firebase Console](https://console.firebase.google.com/)
- [ ] Create new project: "KOMIKAP"
- [ ] Wait for project creation to complete

### Phase 2: Add Android App (5 minutes)

- [ ] In Firebase Console, click "Add app" → Android
- [ ] Package name: `com.example.komikap`
- [ ] App nickname: `KOMIKAP Android`
- [ ] Download `google-services.json`
- [ ] Place file in: `android/app/google-services.json`
- [ ] Click "Next" and "Continue to console"

### Phase 3: Add iOS App (5 minutes)

- [ ] In Firebase Console, click "Add app" → iOS
- [ ] Bundle ID: `com.example.komikap`
- [ ] App nickname: `KOMIKAP iOS`
- [ ] Download `GoogleService-Info.plist`
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Drag `GoogleService-Info.plist` into Xcode (check "Copy items if needed")
- [ ] Click "Next" and "Continue to console"

### Phase 4: Enable Firebase Services (2 minutes)

In Firebase Console:

- [ ] Go to **Authentication**
  - [ ] Click "Get Started"
  - [ ] Enable "Email/Password"
  - [ ] Enable "Google" (optional, for later)

- [ ] Go to **Firestore Database**
  - [ ] Click "Create database"
  - [ ] Select region: `asia-southeast1` (or closest to you)
  - [ ] Start in **Production mode**
  - [ ] Click "Create"

- [ ] Go to **Storage**
  - [ ] Click "Get started"
  - [ ] Accept default rules
  - [ ] Click "Done"

### Phase 5: Set Firestore Security Rules (2 minutes)

- [ ] Go to **Firestore Database** → **Rules**
- [ ] Replace all content with rules from `FIREBASE_SETUP_GUIDE.md` (Section 7)
- [ ] Click "Publish"

### Phase 6: Create Firestore Indexes (1 minute)

- [ ] Go to **Firestore Database** → **Indexes**
- [ ] Create index for `posts` collection:
  - [ ] Collection: `posts`
  - [ ] Field: `createdAt` (Descending)
  - [ ] Click "Create Index"

- [ ] Create index for `users.savedManga`:
  - [ ] Collection: `users`
  - [ ] Collection group: `savedManga`
  - [ ] Field: `lastReadAt` (Descending)
  - [ ] Click "Create Index"

### Phase 7: Verify Flutter Integration (2 minutes)

- [ ] Run: `flutter pub get`
- [ ] Run: `flutter doctor -v` (check Firebase setup)
- [ ] Verify no compilation errors

### Phase 8: Test Authentication (5 minutes)

- [ ] Run app: `flutter run`
- [ ] Go to Sign Up screen
- [ ] Create test account:
  - Email: `test@example.com`
  - Password: `Test123456`
  - Username: `testuser`
- [ ] Verify account created in Firebase Console → Authentication
- [ ] Go to Login screen
- [ ] Login with test account
- [ ] Verify successful login and navigation to MainScreen

### Phase 9: Verify Firestore Data (2 minutes)

- [ ] Go to Firebase Console → Firestore Database
- [ ] Check `users` collection
- [ ] Verify test user document created with:
  - [ ] `uid`
  - [ ] `username`
  - [ ] `email`
  - [ ] `createdAt`
  - [ ] `updatedAt`

---

## 📋 What's Already Done

✅ **Code Implementation**
- AuthService.dart - Firebase authentication
- firebase_service.dart - Firestore operations
- local_cache_service.dart - SQLite caching
- firebase_models.dart - Data models
- firebase_providers.dart - Riverpod state management
- loginscreen.dart - Integrated with Firebase
- signupscreen.dart - Integrated with Firebase
- main.dart - Firebase initialized

✅ **Dependencies**
- firebase_core: ^3.15.2
- cloud_firestore: ^5.0.0
- firebase_auth: ^5.7.0
- firebase_storage: ^12.0.0
- sqflite: ^2.3.0
- uuid: ^4.0.0

---

## 🔧 Configuration Files

### Android Setup

**File: `android/app/build.gradle`**

Verify these lines exist:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
    }
}

dependencies {
    // Firebase is handled by Flutter plugins
}
```

**File: `android/build.gradle`**

Verify:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

**File: `android/app/build.gradle`**

Verify at bottom:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### iOS Setup

**File: `ios/Podfile`**

Verify minimum iOS version:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'FIREBASE_ANALYTICS_COLLECTION_ENABLED=1',
      ]
    end
  end
end
```

---

## 🧪 Testing Checklist

### Authentication Tests

- [ ] Sign up with valid email/password
- [ ] Sign up with existing email (should fail)
- [ ] Sign up with weak password (should fail)
- [ ] Sign up with invalid email (should fail)
- [ ] Login with correct credentials
- [ ] Login with wrong password (should fail)
- [ ] Login with non-existent email (should fail)
- [ ] Logout and verify session cleared
- [ ] Password reset email sent

### Data Persistence Tests

- [ ] Create account and verify in Firebase Console
- [ ] Save manga and verify in Firestore
- [ ] Close and reopen app
- [ ] Verify saved manga still visible
- [ ] Verify local cache working

### Offline Tests

- [ ] Turn off internet
- [ ] Try to login (should fail gracefully)
- [ ] Turn on internet
- [ ] Login successfully
- [ ] Verify cached data loads

---

## ⚠️ Common Issues & Solutions

### Issue: `google-services.json` not found

**Solution:**
```bash
# Verify file exists
ls android/app/google-services.json

# If missing, download from Firebase Console again
# Project Settings → Your apps → Android → Download google-services.json
```

### Issue: Firestore rules rejection

**Solution:**
1. Go to Firebase Console → Firestore → Rules
2. Check rules are published (green checkmark)
3. Verify user is authenticated before Firestore calls

### Issue: "PlatformException: Sign in failed"

**Solution:**
1. Verify Firebase project created successfully
2. Check Android/iOS apps added to Firebase project
3. Verify `google-services.json` and `GoogleService-Info.plist` in correct locations
4. Run `flutter clean` and `flutter pub get`

### Issue: SQLite database not creating

**Solution:**
```dart
// Check permissions in AndroidManifest.xml
// android/app/src/main/AndroidManifest.xml should have:
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

---

## 📞 Support Resources

- **Firebase Docs**: https://firebase.google.com/docs
- **Flutter Firebase**: https://firebase.flutter.dev/
- **Firestore Security**: https://firebase.google.com/docs/firestore/security
- **Firebase Auth**: https://firebase.google.com/docs/auth

---

## ✅ Completion Status

**Total Steps**: 9 phases + testing

**Estimated Time**: 30-45 minutes

**Current Status**: Code implementation complete ✅
**Next**: Firebase Console setup (your turn!)

---

## 🎯 After Setup

Once Firebase is configured:

1. Test authentication with login/signup screens
2. Create test user account
3. Verify data in Firebase Console
4. Start building next features:
   - User profile screen
   - Saved manga management
   - Community feed
   - Download manager

**You're ready to go! 🚀**
