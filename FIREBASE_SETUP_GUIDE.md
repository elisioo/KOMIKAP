# Firebase Implementation Guide for KOMIKAP

## Overview
This guide covers the complete Firebase setup for KOMIKAP, including Firestore database structure, authentication, storage, and local caching.

---

## 1. Firebase Project Setup

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Name it "KOMIKAP"
4. Enable Google Analytics (optional)
5. Create the project

### Step 2: Add Apps to Firebase Project
1. Go to Project Settings
2. Add Android app:
   - Package name: `com.example.komikap`
   - SHA-1 fingerprint (get from: `flutter run` or `keytool -list -v -keystore ~/.android/debug.keystore`)
   - Download `google-services.json` and place in `android/app/`

3. Add iOS app:
   - Bundle ID: `com.example.komikap`
   - Download `GoogleService-Info.plist` and add to iOS project

### Step 3: Enable Services
In Firebase Console:
- ✅ Authentication (Email/Password)
- ✅ Firestore Database
- ✅ Cloud Storage
- ✅ Realtime Database (optional, for real-time features)

---

## 2. Firestore Database Structure

### Collections Overview

```
firestore/
├── users/
│   ├── {uid}/
│   │   ├── username: string
│   │   ├── email: string
│   │   ├── profileImageUrl: string (nullable)
│   │   ├── bio: string
│   │   ├── createdAt: timestamp
│   │   ├── updatedAt: timestamp
│   │   ├── followersCount: number
│   │   ├── followingCount: number
│   │   └── savedManga/ (subcollection)
│   │       ├── {mangaId}/
│   │       │   ├── id: string
│   │       │   ├── uid: string
│   │       │   ├── mangaId: string
│   │       │   ├── title: string
│   │       │   ├── coverImageUrl: string (nullable)
│   │       │   ├── lastChapterRead: number
│   │       │   ├── savedAt: timestamp
│   │       │   ├── lastReadAt: timestamp
│   │       │   └── isFavorite: boolean
│   │
├── posts/
│   ├── {postId}/
│   │   ├── id: string
│   │   ├── uid: string
│   │   ├── username: string
│   │   ├── userProfileImageUrl: string (nullable)
│   │   ├── content: string
│   │   ├── imageUrl: string (nullable)
│   │   ├── likesCount: number
│   │   ├── commentsCount: number
│   │   ├── createdAt: timestamp
│   │   ├── updatedAt: timestamp
│   │   ├── likedBy: array<string> (UIDs)
│   │   └── comments/ (subcollection)
│   │       ├── {commentId}/
│   │       │   ├── id: string
│   │       │   ├── postId: string
│   │       │   ├── uid: string
│   │       │   ├── username: string
│   │       │   ├── userProfileImageUrl: string (nullable)
│   │       │   ├── content: string
│   │       │   ├── likesCount: number
│   │       │   ├── createdAt: timestamp
│   │       │   ├── updatedAt: timestamp
│   │       │   └── likedBy: array<string> (UIDs)
```

### SQLite Local Database Tables

#### 1. cache_entries
```sql
CREATE TABLE cache_entries (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  createdAt INTEGER NOT NULL,
  expiresAt INTEGER NOT NULL
);
```
**Purpose**: Cache API responses for offline access and faster loading

#### 2. downloaded_chapters
```sql
CREATE TABLE downloaded_chapters (
  id TEXT PRIMARY KEY,
  mangaId TEXT NOT NULL,
  chapterId TEXT NOT NULL,
  chapterTitle TEXT NOT NULL,
  chapterNumber INTEGER NOT NULL,
  pageImagePaths TEXT NOT NULL,  -- Pipe-separated paths
  downloadedAt INTEGER NOT NULL,
  sizeInBytes INTEGER NOT NULL
);
```
**Purpose**: Store downloaded manga chapters for offline reading

#### 3. saved_manga
```sql
CREATE TABLE saved_manga (
  id TEXT PRIMARY KEY,
  uid TEXT NOT NULL,
  mangaId TEXT NOT NULL,
  title TEXT NOT NULL,
  coverImageUrl TEXT,
  lastChapterRead INTEGER NOT NULL,
  savedAt INTEGER NOT NULL,
  lastReadAt INTEGER NOT NULL,
  isFavorite INTEGER NOT NULL
);
```
**Purpose**: Local copy of saved manga for offline access

---

## 3. Firestore Security Rules

Add these rules to Firestore in Firebase Console:

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

---

## 4. Cloud Storage Structure

```
storage/
├── users/
│   ├── {uid}/
│   │   └── profile.jpg
├── posts/
│   ├── {uid}/
│   │   ├── {postId1}.jpg
│   │   ├── {postId2}.jpg
```

---

## 5. Usage Examples

### Authentication
```dart
final firebaseService = FirebaseService();

// Register
await firebaseService.registerUser(
  email: 'user@example.com',
  password: 'password123',
  username: 'username',
);

// Login
await firebaseService.loginUser(
  email: 'user@example.com',
  password: 'password123',
);

// Logout
await firebaseService.logoutUser();
```

### User Profile
```dart
// Get profile
final profile = await firebaseService.getUserProfile(uid);

// Update profile
await firebaseService.updateUserProfile(uid, {
  'bio': 'New bio',
  'profileImageUrl': 'url',
});
```

### Saved Manga
```dart
// Save manga
await firebaseService.saveManga(
  uid: uid,
  mangaId: 'manga123',
  title: 'Manga Title',
  coverImageUrl: 'url',
);

// Get saved manga
final saved = await firebaseService.getSavedManga(uid);

// Toggle favorite
await firebaseService.toggleFavoriteManga(uid, 'manga123', true);

// Update reading progress
await firebaseService.updateLastChapterRead(uid, 'manga123', 5);
```

### Posts & Comments
```dart
// Create post
final postId = await firebaseService.createPost(
  uid: uid,
  username: username,
  content: 'Post content',
  imageUrl: 'optional_image_url',
);

// Get posts
final posts = await firebaseService.getPosts(limit: 20);

// Add comment
final commentId = await firebaseService.addComment(
  postId: postId,
  uid: uid,
  username: username,
  content: 'Comment text',
);

// Like post
await firebaseService.likePost(postId, uid);

// Unlike post
await firebaseService.unlikePost(postId, uid);
```

### Local Caching
```dart
final cacheService = LocalCacheService();

// Cache data
await cacheService.cacheData(
  'manga_list',
  jsonEncode(mangaList),
  ttl: Duration(hours: 24),
);

// Get cached data
final cached = await cacheService.getCachedData('manga_list');

// Save downloaded chapter
await cacheService.saveDownloadedChapter(chapter);

// Get downloaded chapters
final downloaded = await cacheService.getDownloadedChaptersByManga(mangaId);
```

---

## 6. Riverpod Provider Usage

### In Widgets
```dart
// Get current user
final user = ref.watch(currentUserProvider);

// Get user profile
final profile = ref.watch(userProfileProvider(uid));

// Get saved manga
final savedManga = ref.watch(savedMangaProvider(uid));

// Get posts
final posts = ref.watch(postsProvider);

// Get comments
final comments = ref.watch(commentsProvider(postId));

// Mutations
await ref.read(savedMangaNotifierProvider(uid).notifier).saveManga(
  mangaId: 'manga123',
  title: 'Title',
);

await ref.read(postsNotifierProvider.notifier).createPost(
  uid: uid,
  username: username,
  content: 'Post content',
);
```

---

## 7. Offline-First Strategy

### Caching Layers
1. **API Response Cache** (SQLite) - Cached API responses with TTL
2. **Downloaded Chapters** (SQLite) - Full chapters for offline reading
3. **Saved Manga** (SQLite) - Local copy synced with Firestore
4. **Firestore** - Cloud source of truth

### Sync Strategy
```dart
// When user goes online, sync local changes to Firestore
Future<void> syncLocalChanges() async {
  final localManga = await cacheService.getAllSavedMangaLocally(uid);
  for (var manga in localManga) {
    await firebaseService.saveManga(
      uid: uid,
      mangaId: manga.mangaId,
      title: manga.title,
      coverImageUrl: manga.coverImageUrl,
    );
  }
}
```

---

## 8. Performance Optimization

### Firestore Indexes
Create composite indexes for:
- `posts` collection: `createdAt` (descending)
- `users.savedManga` subcollection: `lastReadAt` (descending)
- `posts.comments` subcollection: `createdAt` (descending)

### Pagination
```dart
// Implement pagination for posts
Query query = _firestore
    .collection('posts')
    .orderBy('createdAt', descending: true)
    .limit(20);

// For next page
query = query.startAfterDocument(lastDocument);
```

### Batch Operations
```dart
// Use batch writes for multiple operations
final batch = _firestore.batch();
batch.set(userRef, userData);
batch.set(postRef, postData);
await batch.commit();
```

---

## 9. Testing

### Firebase Emulator Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize emulator
firebase init emulator

# Start emulator
firebase emulators:start
```

### Update connection in code
```dart
if (kDebugMode) {
  await FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}
```

---

## 10. Common Issues & Solutions

### Issue: Firestore quota exceeded
**Solution**: Implement caching and pagination

### Issue: Slow image uploads
**Solution**: Compress images before upload, use Cloud Functions for optimization

### Issue: Offline sync conflicts
**Solution**: Use timestamps and last-write-wins strategy

### Issue: Large downloads
**Solution**: Implement chunk-based downloads and resume capability

---

## 11. Next Steps

1. ✅ Set up Firebase project
2. ✅ Configure Android/iOS apps
3. ✅ Set Firestore security rules
4. ✅ Create database indexes
5. ✅ Implement authentication UI
6. ✅ Create user profile screen
7. ✅ Implement saved manga feature
8. ✅ Create community feed (posts/comments)
9. ✅ Add download manager
10. ✅ Implement offline sync

---

## 12. File Structure Reference

```
lib/
├── models/
│   ├── firebase_models.dart       # All Firebase data models
│   └── mangadexmanga.dart         # Existing MangaDex models
├── services/
│   ├── firebase_service.dart      # Firebase operations
│   ├── local_cache_service.dart   # SQLite caching
│   └── api/
│       └── mangadexapiservice.dart # Existing API service
├── state/
│   ├── firebase_providers.dart    # Firebase Riverpod providers
│   └── manga_providers.dart       # Existing manga providers
└── pages/
    ├── auth/
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── profile_screen.dart
    ├── saved_manga_screen.dart
    ├── community_feed_screen.dart
    └── download_manager_screen.dart
```

---

## 13. Dependencies Added

```yaml
firebase_core: ^4.2.1
cloud_firestore: ^5.0.0
firebase_auth: ^5.1.0
firebase_storage: ^12.0.0
sqflite: ^2.3.0
path: ^1.8.3
uuid: ^4.0.0
```

All dependencies are already added to `pubspec.yaml`.

---

## Support & Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Cloud Firestore Guide](https://firebase.google.com/docs/firestore)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Storage](https://firebase.google.com/docs/storage)
- [Flutter Firebase Plugin](https://firebase.flutter.dev/)
