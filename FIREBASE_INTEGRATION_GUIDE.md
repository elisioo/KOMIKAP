# Firebase & Local Database Integration Guide - KOMIKAP

## ✅ What's Been Implemented

### 1. **Firebase Authentication Service** (`lib/services/AuthService.dart`)
- ✅ Email/Password Sign In with Firebase
- ✅ Email/Password Sign Up with Firebase
- ✅ Password Reset via Email
- ✅ Logout with local cache clearing
- ✅ Token validation
- ✅ Google Sign-In support (template ready)
- ✅ Firebase error handling with user-friendly messages
- ✅ Local caching of user data on login

### 2. **Firebase Service** (`lib/services/firebase_service.dart`)
- ✅ User Profile Management (Create, Read, Update)
- ✅ Saved Manga Management (Save, Remove, Get, Toggle Favorite)
- ✅ Reading Progress Tracking
- ✅ Posts & Comments (Create, Delete, List)
- ✅ Like/Unlike functionality
- ✅ Image Upload to Cloud Storage

### 3. **Local SQLite Cache** (`lib/services/local_cache_service.dart`)
- ✅ API Response Caching with TTL
- ✅ Downloaded Chapters Storage
- ✅ Saved Manga Local Copy
- ✅ Offline-first support

### 4. **Data Models** (`lib/models/firebase_models.dart`)
- ✅ UserProfile
- ✅ SavedManga
- ✅ Post
- ✅ Comment
- ✅ DownloadedChapter
- ✅ CacheEntry

### 5. **Riverpod State Management** (`lib/state/firebase_providers.dart`)
- ✅ Auth state provider
- ✅ User profile provider
- ✅ Saved manga providers
- ✅ Posts & comments providers
- ✅ Downloaded chapters provider
- ✅ StateNotifiers for mutations

---

## 🔧 Setup Instructions

### Step 1: Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "KOMIKAP"
3. Add Android app:
   - Package name: `com.example.komikap`
   - Download `google-services.json`
   - Place in `android/app/google-services.json`

4. Add iOS app:
   - Bundle ID: `com.example.komikap`
   - Download `GoogleService-Info.plist`
   - Add to iOS project via Xcode

### Step 2: Enable Firebase Services

In Firebase Console, enable:
- ✅ Authentication (Email/Password)
- ✅ Firestore Database
- ✅ Cloud Storage

### Step 3: Set Firestore Security Rules

Go to Firestore → Rules and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{uid} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == uid;
      allow update: if request.auth.uid == uid;
      allow delete: if request.auth.uid == uid;
      
      // Saved manga subcollection
      match /savedManga/{mangaId} {
        allow read: if request.auth.uid == uid;
        allow write: if request.auth.uid == uid;
      }
    }
    
    // Posts collection
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.uid;
      allow delete: if request.auth.uid == resource.data.uid;
      
      // Comments subcollection
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

### Step 4: Create Firestore Indexes

Go to Firestore → Indexes and create:

1. **Posts Collection**
   - Field: `createdAt` (Descending)

2. **Users → SavedManga Subcollection**
   - Field: `lastReadAt` (Descending)

3. **Posts → Comments Subcollection**
   - Field: `createdAt` (Descending)

---

## 📱 Usage Examples

### Authentication

```dart
final authService = AuthService();

// Sign Up
final signupResult = await authService.signUpWithEmail(
  email: 'user@example.com',
  password: 'password123',
  username: 'username',
);

if (signupResult.success) {
  print('User created: ${signupResult.userId}');
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(signupResult.message)),
  );
}

// Login
final loginResult = await authService.signInWithEmail(
  'user@example.com',
  'password123',
);

// Logout
await authService.logout();

// Check if authenticated
if (authService.isAuthenticated) {
  print('User ID: ${authService.currentUserId}');
}
```

### Saved Manga

```dart
final firebaseService = FirebaseService();

// Save manga
await firebaseService.saveManga(
  uid: userId,
  mangaId: 'manga123',
  title: 'Manga Title',
  coverImageUrl: 'https://...',
);

// Get saved manga
final savedManga = await firebaseService.getSavedManga(userId);

// Toggle favorite
await firebaseService.toggleFavoriteManga(userId, 'manga123', true);

// Update reading progress
await firebaseService.updateLastChapterRead(userId, 'manga123', 5);
```

### Posts & Comments

```dart
// Create post
final postId = await firebaseService.createPost(
  uid: userId,
  username: 'username',
  content: 'Check out this manga!',
  imageUrl: 'optional_image_url',
);

// Get posts
final posts = await firebaseService.getPosts(limit: 20);

// Like post
await firebaseService.likePost(postId, userId);

// Add comment
final commentId = await firebaseService.addComment(
  postId: postId,
  uid: userId,
  username: 'username',
  content: 'Great manga!',
);

// Like comment
await firebaseService.likeComment(postId, commentId, userId);
```

### Local Caching

```dart
final cacheService = LocalCacheService();

// Cache API response
await cacheService.cacheData(
  'manga_list_key',
  jsonEncode(mangaList),
  ttl: Duration(hours: 24),
);

// Get cached data
final cached = await cacheService.getCachedData('manga_list_key');

// Save downloaded chapter
await cacheService.saveDownloadedChapter(chapter);

// Get downloaded chapters
final downloaded = await cacheService.getDownloadedChaptersByManga(mangaId);
```

---

## 🎯 Integration with Existing Screens

### Login Screen Integration

Your `loginscreen.dart` already uses `AuthService`. The new Firebase integration:
- ✅ Authenticates against Firebase
- ✅ Creates user profile in Firestore
- ✅ Caches user data locally
- ✅ Shows Firebase error messages

### Sign Up Screen Integration

Your `signupscreen.dart` already uses `AuthService`. The new Firebase integration:
- ✅ Creates Firebase user account
- ✅ Creates Firestore user profile
- ✅ Validates password strength
- ✅ Handles duplicate email errors

### Next Steps for Other Screens

1. **Profile Screen** - Display user profile from Firestore
2. **Library Screen** - Show saved manga from Firestore
3. **Community Screen** - Display posts from Firestore
4. **Reader Screen** - Track reading progress in Firestore

---

## 🔐 Security Best Practices

### 1. **Never Hardcode Credentials**
```dart
// ❌ DON'T DO THIS
const String apiKey = "AIzaSyD...";

// ✅ DO THIS - Use Firebase Console configuration
// Firebase handles credentials automatically
```

### 2. **Validate on Client & Server**
```dart
// Client-side validation (UX)
if (email.isEmpty) return 'Email required';

// Server-side validation (Security)
// Firestore rules enforce this
```

### 3. **Use HTTPS Only**
- All Firebase communications are HTTPS by default
- Never use HTTP for sensitive data

### 4. **Implement Rate Limiting**
- Firebase Auth has built-in rate limiting
- Firestore rules can add custom limits

---

## 📊 Database Structure

### Firestore Collections

```
firestore/
├── users/{uid}
│   ├── username: string
│   ├── email: string
│   ├── profileImageUrl: string (nullable)
│   ├── bio: string
│   ├── createdAt: timestamp
│   ├── updatedAt: timestamp
│   ├── followersCount: number
│   ├── followingCount: number
│   └── savedManga/{mangaId}
│       ├── id: string
│       ├── mangaId: string
│       ├── title: string
│       ├── coverImageUrl: string
│       ├── lastChapterRead: number
│       ├── savedAt: timestamp
│       ├── lastReadAt: timestamp
│       └── isFavorite: boolean
│
└── posts/{postId}
    ├── id: string
    ├── uid: string
    ├── username: string
    ├── content: string
    ├── imageUrl: string (nullable)
    ├── likesCount: number
    ├── commentsCount: number
    ├── createdAt: timestamp
    ├── likedBy: array<string>
    └── comments/{commentId}
        ├── id: string
        ├── uid: string
        ├── username: string
        ├── content: string
        ├── likesCount: number
        ├── createdAt: timestamp
        └── likedBy: array<string>
```

### SQLite Tables

```
cache_entries
├── key: TEXT (PRIMARY KEY)
├── value: TEXT
├── createdAt: INTEGER
└── expiresAt: INTEGER

downloaded_chapters
├── id: TEXT (PRIMARY KEY)
├── mangaId: TEXT
├── chapterId: TEXT
├── chapterTitle: TEXT
├── chapterNumber: INTEGER
├── pageImagePaths: TEXT (pipe-separated)
├── downloadedAt: INTEGER
└── sizeInBytes: INTEGER

saved_manga
├── id: TEXT (PRIMARY KEY)
├── uid: TEXT
├── mangaId: TEXT
├── title: TEXT
├── coverImageUrl: TEXT
├── lastChapterRead: INTEGER
├── savedAt: INTEGER
├── lastReadAt: INTEGER
└── isFavorite: INTEGER
```

---

## 🧪 Testing

### Test Email/Password Auth

```dart
// In your test file
void main() {
  test('Sign up with Firebase', () async {
    final authService = AuthService();
    final result = await authService.signUpWithEmail(
      email: 'test@example.com',
      password: 'password123',
      username: 'testuser',
    );
    
    expect(result.success, true);
    expect(result.userId, isNotNull);
  });
}
```

### Use Firebase Emulator (Development)

```dart
// In main.dart (development only)
if (kDebugMode) {
  await FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}
```

---

## 🐛 Troubleshooting

### Issue: "user-not-found" error
**Solution**: User doesn't exist. Check email or create account first.

### Issue: "wrong-password" error
**Solution**: Password is incorrect. Suggest password reset.

### Issue: "email-already-in-use" error
**Solution**: Email already registered. Suggest login or password reset.

### Issue: Firestore rules rejection
**Solution**: Check security rules in Firebase Console. Ensure user is authenticated.

### Issue: Local cache not syncing
**Solution**: Call `syncSavedMangaToFirestore()` when online.

---

## 📝 File Structure

```
lib/
├── services/
│   ├── AuthService.dart ✅ (Updated with Firebase)
│   ├── firebase_service.dart ✅ (Created)
│   ├── local_cache_service.dart ✅ (Created)
│   └── api/
│       └── mangadexapiservice.dart
├── models/
│   ├── firebase_models.dart ✅ (Created)
│   └── mangadexmanga.dart
├── state/
│   ├── firebase_providers.dart ✅ (Created)
│   └── manga_providers.dart
├── pages/
│   ├── auth/
│   │   ├── loginscreen.dart ✅ (Uses Firebase)
│   │   ├── signupscreen.dart ✅ (Uses Firebase)
│   │   └── forgotpasswordscreen.dart
│   ├── libraryscreen.dart
│   ├── profilescreen.dart
│   ├── communityscreen.dart
│   └── ...
└── main.dart ✅ (Firebase initialized)
```

---

## ✨ Next Steps

1. ✅ **Authentication** - Login/Signup screens integrated
2. ⏭️ **User Profile Screen** - Display/edit profile from Firestore
3. ⏭️ **Saved Manga Screen** - Show saved manga with reading progress
4. ⏭️ **Community Feed** - Display posts and comments
5. ⏭️ **Download Manager** - Manage offline chapters
6. ⏭️ **Sync Service** - Sync local changes to Firestore

---

## 📚 Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Cloud Firestore Guide](https://firebase.google.com/docs/firestore)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Flutter Firebase Plugin](https://firebase.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)

---

## 🎉 Summary

Your KOMIKAP app now has:
- ✅ Real Firebase authentication
- ✅ Firestore database for user data
- ✅ Local SQLite caching for offline support
- ✅ Riverpod state management
- ✅ Production-ready error handling
- ✅ Secure user profiles and saved manga

**Ready to build the next features!**
