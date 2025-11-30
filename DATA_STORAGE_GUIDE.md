# Data Storage Guide - KOMIKAP

## 📊 Where Your Data is Stored

Your KOMIKAP app uses **two different storage systems**:

1. **Firebase (Cloud)** - For posts, comments, likes, saved manga, favorites
2. **SQLite (Local)** - For downloaded chapters and API cache

---

## ☁️ Firebase Cloud Storage

### What Gets Stored in Firebase:

#### 1. **User Accounts**
```
Firestore Collection: users/{uid}
├── email: string
├── displayName: string
├── photoURL: string
├── createdAt: timestamp
└── lastLogin: timestamp
```

**How it works:**
- When you sign up, your account is created in Firebase Authentication
- Your profile is saved in Firestore
- This data is stored on Google's servers (cloud)
- Accessible from any device after login

#### 2. **Posts & Comments**
```
Firestore Collection: posts/{postId}
├── id: string
├── uid: string (user ID)
├── username: string
├── content: string
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

**How it works:**
- When you create a post, it's sent to Firebase
- Firebase stores it on their servers
- All users can see your post
- Comments are stored as subcollections
- Likes are tracked in the `likedBy` array

#### 3. **Saved Manga & Favorites**
```
Firestore Collection: users/{uid}/savedManga/{mangaId}
├── id: string
├── mangaId: string
├── title: string
├── coverImageUrl: string
├── lastChapterRead: number
├── savedAt: timestamp
├── lastReadAt: timestamp
└── isFavorite: boolean
```

**How it works:**
- When you save a manga, it's stored in your user's collection
- Only you can see your saved manga
- Favorites are marked with `isFavorite: true`
- This data syncs across all your devices

---

## 💾 SQLite Local Storage

### What Gets Stored Locally:

#### 1. **Downloaded Chapters**
```
SQLite Table: downloaded_chapters
├── id: TEXT PRIMARY KEY
├── mangaId: TEXT
├── chapterId: TEXT
├── chapterTitle: TEXT
├── chapterNumber: INTEGER
├── pageImagePaths: TEXT (pipe-separated URLs)
├── downloadedAt: INTEGER (timestamp)
└── sizeInBytes: INTEGER
```

**How it works:**
- When you download a chapter, it's stored on your device
- Stored in: `/data/data/com.example.komikap/databases/komikap_cache.db`
- Only accessible on your device
- Persists even if you close the app
- Can be accessed offline

**Example:**
```
ID: manga123_chapter1
Manga ID: manga123
Chapter: Chapter 1: The Beginning
Pages: 20
Size: 10.5 MB
Downloaded: Nov 30, 2025 3:45 PM
```

#### 2. **API Response Cache**
```
SQLite Table: cache_entries
├── key: TEXT PRIMARY KEY
├── value: TEXT (JSON response)
├── createdAt: INTEGER (timestamp)
└── expiresAt: INTEGER (timestamp)
```

**How it works:**
- Caches API responses for faster loading
- Automatically expires after TTL (Time To Live)
- Reduces network requests
- Improves app performance

---

## 🔄 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Your KOMIKAP App                         │
└─────────────────────────────────────────────────────────────┘
                    ↓                    ↓
        ┌───────────────────┐  ┌────────────────────┐
        │   Firebase Cloud  │  │  SQLite Local DB   │
        │   (Cloud Storage) │  │  (Device Storage)  │
        └───────────────────┘  └────────────────────┘
                ↓                        ↓
    ┌─────────────────────┐   ┌──────────────────┐
    │ • User Accounts     │   │ • Downloaded     │
    │ • Posts & Comments  │   │   Chapters       │
    │ • Likes             │   │ • API Cache      │
    │ • Saved Manga       │   │                  │
    │ • Favorites         │   │ (Offline Access) │
    │                     │   │                  │
    │ (Cloud Sync)        │   │ (Local Only)     │
    └─────────────────────┘   └──────────────────┘
```

---

## 📱 Storage Locations

### Firebase (Cloud):
- **Server**: Google Firebase Servers
- **Access**: From any device after login
- **Sync**: Automatic across devices
- **Backup**: Automatic by Google

### SQLite (Local):
- **Android**: `/data/data/com.example.komikap/databases/komikap_cache.db`
- **Access**: Only on this device
- **Sync**: Manual (not synced to cloud)
- **Backup**: Only if you backup your device

---

## 🔐 Data Persistence

### Firebase Data:
```
✅ Persists after app close
✅ Persists after device restart
✅ Accessible from any device (after login)
✅ Synced automatically
✅ Backed up by Google
```

### SQLite Data:
```
✅ Persists after app close
✅ Persists after device restart
❌ Only on this device
❌ Not synced to cloud
⚠️  Lost if app is uninstalled (unless backed up)
```

---

## 📊 How Each Feature Stores Data

### 1. **Creating a Post**
```
User writes: "Just finished Jujutsu Kaisen!"
         ↓
    App validates
         ↓
    Sends to Firebase
         ↓
    Firebase stores in: posts/{postId}
         ↓
    All users can see it
         ↓
    Appears in Community Feed
```

**Storage:** Firebase Cloud ☁️

### 2. **Liking a Post**
```
User taps heart icon
         ↓
    App sends like to Firebase
         ↓
    Firebase adds user ID to: posts/{postId}/likedBy[]
         ↓
    Like count increases
         ↓
    Heart turns red
```

**Storage:** Firebase Cloud ☁️

### 3. **Adding a Comment**
```
User writes comment
         ↓
    App sends to Firebase
         ↓
    Firebase stores in: posts/{postId}/comments/{commentId}
         ↓
    Comment appears in post
         ↓
    Comment count increases
```

**Storage:** Firebase Cloud ☁️

### 4. **Saving a Manga**
```
User taps "Save" button
         ↓
    App sends to Firebase
         ↓
    Firebase stores in: users/{uid}/savedManga/{mangaId}
         ↓
    Appears in "Saved Manga" screen
         ↓
    Syncs to all your devices
```

**Storage:** Firebase Cloud ☁️

### 5. **Adding to Favorites**
```
User taps "Favorite" button
         ↓
    App sets isFavorite: true in Firebase
         ↓
    Firebase updates: users/{uid}/savedManga/{mangaId}
         ↓
    Appears in "Favorites" screen
         ↓
    Syncs to all your devices
```

**Storage:** Firebase Cloud ☁️

### 6. **Downloading a Chapter**
```
User taps download icon
         ↓
    App downloads pages
         ↓
    Stores in SQLite: downloaded_chapters table
         ↓
    Appears in "Downloads" screen
         ↓
    Can read offline
```

**Storage:** SQLite Local 💾

---

## ✅ Verification Checklist

### To verify Firebase storage is working:

1. **Check Firestore Console:**
   - Go to Firebase Console
   - Select your project
   - Go to Firestore Database
   - Check collections:
     - `posts` - Your posts
     - `users/{uid}/savedManga` - Your saved manga
     - `users/{uid}` - Your profile

2. **Check in App:**
   - Create a post → See it in Community Feed
   - Like a post → Heart turns red
   - Add comment → See comment count increase
   - Save manga → See in "Saved Manga" screen
   - Add favorite → See in "Favorites" screen

### To verify SQLite storage is working:

1. **Check Downloads Screen:**
   - Download a chapter
   - Go to Profile → Downloads
   - See total download size
   - See downloaded chapters

2. **Check Device Storage:**
   - Use Android Studio Device File Explorer
   - Navigate to: `/data/data/com.example.komikap/databases/`
   - Find: `komikap_cache.db`
   - Download and open with DB Browser

---

## 🐛 Troubleshooting

### Posts not appearing:
- ✅ Check internet connection
- ✅ Check Firebase is initialized
- ✅ Check Firestore security rules allow writes
- ✅ Check user is logged in

### Saved manga not syncing:
- ✅ Check internet connection
- ✅ Check Firebase is initialized
- ✅ Check user is logged in
- ✅ Try logging out and back in

### Downloads not saving:
- ✅ Check device has storage space
- ✅ Check app has storage permissions
- ✅ Check SQLite is initialized
- ✅ Check error message in console

### Data lost after uninstall:
- ⚠️ Firebase data: Preserved (login to recover)
- ⚠️ SQLite data: Lost (not backed up)
- 💡 Solution: Backup your device regularly

---

## 📈 Data Limits

### Firebase:
- **Free Tier**: 1 GB storage, 50k reads/day
- **Paid Tier**: Unlimited (pay per use)
- **Quota**: Depends on plan

### SQLite:
- **Device Storage**: Depends on your phone
- **Typical**: 100-500 MB available
- **Per Chapter**: ~10-50 MB

---

## 🔄 Syncing & Offline

### Firebase (Cloud):
- **Online**: Real-time sync
- **Offline**: Queued for sync
- **Reconnect**: Automatic sync

### SQLite (Local):
- **Online**: Works
- **Offline**: Works (no sync needed)
- **Reconnect**: No sync (local only)

---

## 🎯 Best Practices

### For Cloud Data (Firebase):
1. ✅ Always login to access your data
2. ✅ Check internet connection for sync
3. ✅ Don't share your password
4. ✅ Enable 2FA for security

### For Local Data (SQLite):
1. ✅ Backup your device regularly
2. ✅ Don't uninstall without backup
3. ✅ Monitor storage space
4. ✅ Clear old downloads if needed

---

## 📚 Related Documentation

- `FIREBASE_INTEGRATION_GUIDE.md` - Firebase setup
- `SQLITE_DATABASE_GUIDE.md` - SQLite details
- `COMMUNITY_AND_DOWNLOADS.md` - Feature details

---

**Summary:**
- **Posts, Comments, Likes, Saved Manga, Favorites** → Firebase Cloud ☁️
- **Downloaded Chapters, API Cache** → SQLite Local 💾
- **Both persist** after app close and device restart
- **Firebase syncs** across devices, **SQLite is local only**

---

**Last Updated**: November 30, 2025
**Version**: 1.0
