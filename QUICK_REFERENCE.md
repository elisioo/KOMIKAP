# Quick Reference Guide - Firebase Integration

## 🚀 Quick Start (TL;DR)

### 1. Firebase Console Setup (30 min)
```
1. Create project at firebase.google.com
2. Add Android app → Download google-services.json → Place in android/app/
3. Add iOS app → Download GoogleService-Info.plist → Add to Xcode
4. Enable: Authentication (Email/Password), Firestore, Storage
5. Set Firestore security rules (copy from FIREBASE_SETUP_GUIDE.md)
6. Create Firestore indexes
```

### 2. Test Authentication (5 min)
```
flutter run
→ Sign Up screen → Create account
→ Verify in Firebase Console
→ Login with credentials
→ Logout
```

### 3. Done! ✅

---

## 📝 Common Code Snippets

### Sign Up
```dart
final authService = AuthService();
final result = await authService.signUpWithEmail(
  email: 'user@example.com',
  password: 'password123',
  username: 'username',
);
if (result.success) {
  // Navigate to MainScreen
} else {
  // Show error: result.message
}
```

### Login
```dart
final result = await authService.signInWithEmail(
  'user@example.com',
  'password123',
);
if (result.success) {
  print('User ID: ${result.userId}');
}
```

### Check if Authenticated
```dart
if (authService.isAuthenticated) {
  print('User ID: ${authService.currentUserId}');
}
```

### Logout
```dart
await authService.logout();
```

### Save Manga
```dart
final firebaseService = FirebaseService();
await firebaseService.saveManga(
  uid: userId,
  mangaId: 'manga123',
  title: 'Manga Title',
  coverImageUrl: 'url',
);
```

### Get Saved Manga
```dart
final savedManga = await firebaseService.getSavedManga(userId);
```

### Create Post
```dart
final postId = await firebaseService.createPost(
  uid: userId,
  username: 'username',
  content: 'Post content',
  imageUrl: 'optional_url',
);
```

### Like Post
```dart
await firebaseService.likePost(postId, userId);
```

### Add Comment
```dart
await firebaseService.addComment(
  postId: postId,
  uid: userId,
  username: 'username',
  content: 'Comment text',
);
```

### Cache Data
```dart
final cacheService = LocalCacheService();
await cacheService.cacheData('key', 'value', ttl: Duration(hours: 24));
final cached = await cacheService.getCachedData('key');
```

---

## 🔧 File Locations

| File | Purpose |
|------|---------|
| `lib/services/AuthService.dart` | Firebase authentication |
| `lib/services/firebase_service.dart` | Firestore operations |
| `lib/services/local_cache_service.dart` | SQLite caching |
| `lib/models/firebase_models.dart` | Data models |
| `lib/state/firebase_providers.dart` | Riverpod providers |
| `lib/pages/auth/loginscreen.dart` | Login UI (integrated) |
| `lib/pages/auth/signupscreen.dart` | Sign up UI (integrated) |
| `android/app/google-services.json` | Android config (download from Firebase) |
| `ios/Runner/GoogleService-Info.plist` | iOS config (download from Firebase) |

---

## 🗄️ Database Collections

### Firestore
```
users/{uid}
  - username, email, bio, profileImageUrl
  - savedManga/{mangaId}
    - title, coverImageUrl, lastChapterRead, isFavorite

posts/{postId}
  - uid, username, content, imageUrl, likesCount
  - comments/{commentId}
    - uid, username, content, likesCount
```

### SQLite
```
cache_entries (key, value, expiresAt)
downloaded_chapters (mangaId, chapterId, pageImagePaths)
saved_manga (uid, mangaId, title, isFavorite)
```

---

## ⚠️ Common Errors & Fixes

| Error | Fix |
|-------|-----|
| `google-services.json not found` | Download from Firebase Console → Place in `android/app/` |
| `GoogleService-Info.plist not found` | Download from Firebase Console → Add to Xcode |
| `Firestore rules rejection` | Check security rules in Firebase Console |
| `user-not-found` | Email doesn't exist, suggest sign up |
| `wrong-password` | Password incorrect, suggest password reset |
| `email-already-in-use` | Email registered, suggest login |
| `weak-password` | Password < 6 characters |
| `too-many-requests` | Too many login attempts, wait and retry |

---

## 🔐 Security Rules (Copy to Firebase Console)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == uid;
      allow update: if request.auth.uid == uid;
      allow delete: if request.auth.uid == uid;
      
      match /savedManga/{mangaId} {
        allow read: if request.auth.uid == uid;
        allow write: if request.auth.uid == uid;
      }
    }
    
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.uid;
      allow delete: if request.auth.uid == resource.data.uid;
      
      match /comments/{commentId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null;
        allow update: if request.auth.uid == resource.data.uid;
        allow delete: if request.auth.uid == resource.data.uid;
      }
    }
  }
}
```

---

## 📦 Dependencies

```yaml
firebase_core: ^3.15.2
cloud_firestore: ^5.0.0
firebase_auth: ^5.7.0
firebase_storage: ^12.0.0
sqflite: ^2.3.0
path: ^1.8.3
uuid: ^4.0.0
```

---

## ✅ Setup Checklist

- [ ] Create Firebase project
- [ ] Add Android app + download google-services.json
- [ ] Add iOS app + download GoogleService-Info.plist
- [ ] Enable Authentication (Email/Password)
- [ ] Enable Firestore Database
- [ ] Enable Cloud Storage
- [ ] Set Firestore security rules
- [ ] Create Firestore indexes
- [ ] Run `flutter pub get`
- [ ] Test sign up
- [ ] Test login
- [ ] Test logout
- [ ] Verify data in Firebase Console

---

## 🎯 Next Features to Build

1. **User Profile Screen** - Display/edit profile from Firestore
2. **Saved Manga Screen** - Show saved manga with reading progress
3. **Community Feed** - Display posts and comments
4. **Download Manager** - Manage offline chapters
5. **Search** - Search saved manga and posts
6. **Notifications** - Notify on new comments/likes

---

## 📚 Documentation

- `FIREBASE_SETUP_GUIDE.md` - Complete setup guide
- `FIREBASE_INTEGRATION_GUIDE.md` - Usage examples
- `FIREBASE_SETUP_CHECKLIST.md` - Step-by-step checklist
- `INTEGRATION_SUMMARY.md` - Overview of implementation

---

## 🔗 Useful Links

- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Docs](https://firebase.google.com/docs)
- [Flutter Firebase](https://firebase.flutter.dev/)
- [Firestore Security](https://firebase.google.com/docs/firestore/security)
- [Riverpod Docs](https://riverpod.dev/)

---

## 💡 Tips

1. **Always check Firebase Console** to verify data creation
2. **Use Firebase Emulator** for local development
3. **Test offline mode** to verify caching works
4. **Monitor Firestore usage** to avoid exceeding quotas
5. **Use composite indexes** for complex queries
6. **Implement pagination** for large datasets
7. **Cache frequently accessed data** locally
8. **Validate on client AND server** for security

---

## 🆘 Need Help?

1. Check **FIREBASE_SETUP_CHECKLIST.md** → "Common Issues & Solutions"
2. Review **FIREBASE_INTEGRATION_GUIDE.md** for usage examples
3. Check Firebase Console for error logs
4. Enable debug logging: `FirebaseAuth.instance.setLanguageCode('en');`

---

**Ready to build! 🚀**
