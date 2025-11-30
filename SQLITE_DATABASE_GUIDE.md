# SQLite Database Guide - KOMIKAP

## 📱 How to View SQLite Database

Your app uses SQLite for local caching and offline support. Here are the ways to view and manage the database:

---

## 🔍 Method 1: Android Studio Device File Explorer (Easiest)

### Steps:
1. **Connect your device or open emulator**
2. **Open Android Studio**
3. **Go to**: View → Tool Windows → Device File Explorer
4. **Navigate to**:
   ```
   /data/data/com.example.komikap/databases/
   ```
5. **Find the database file**:
   ```
   komikap_cache.db
   ```
6. **Right-click** → Download
7. **Open with SQLite viewer** (see Method 3)

---

## 🔍 Method 2: ADB Command Line

### Prerequisites:
- ADB installed (comes with Android SDK)
- Device connected or emulator running

### Steps:

**1. Pull the database file:**
```bash
adb pull /data/data/com.example.komikap/databases/komikap_cache.db
```

**2. Open with SQLite CLI:**
```bash
sqlite3 komikap_cache.db
```

**3. View tables:**
```sql
.tables
```

**4. View table structure:**
```sql
.schema cache_entries
.schema downloaded_chapters
.schema saved_manga
```

**5. Query data:**
```sql
SELECT * FROM cache_entries;
SELECT * FROM downloaded_chapters;
SELECT * FROM saved_manga;
```

**6. Exit:**
```sql
.quit
```

---

## 🔍 Method 3: SQLite Viewer Tools

### Option A: DB Browser for SQLite (Recommended)

**Download**: https://sqlitebrowser.org/

**Steps:**
1. Download and install
2. File → Open Database
3. Select `komikap_cache.db` (downloaded from device)
4. Browse tables and data
5. Run custom SQL queries

### Option B: Online SQLite Viewer

**Website**: https://sqliteviewer.app/

**Steps:**
1. Go to website
2. Upload `komikap_cache.db`
3. Browse tables
4. View data

---

## 📊 Database Schema

### Table 1: `cache_entries`
```sql
CREATE TABLE cache_entries (
  key TEXT PRIMARY KEY,
  value TEXT,
  createdAt INTEGER,
  expiresAt INTEGER
);
```

**Purpose**: Cache API responses with TTL (Time To Live)

**Example Query**:
```sql
SELECT key, LENGTH(value) as size, 
       datetime(createdAt/1000, 'unixepoch') as created,
       datetime(expiresAt/1000, 'unixepoch') as expires
FROM cache_entries;
```

### Table 2: `downloaded_chapters`
```sql
CREATE TABLE downloaded_chapters (
  id TEXT PRIMARY KEY,
  mangaId TEXT,
  chapterId TEXT,
  chapterTitle TEXT,
  chapterNumber INTEGER,
  pageImagePaths TEXT,
  downloadedAt INTEGER,
  sizeInBytes INTEGER
);
```

**Purpose**: Store downloaded chapters for offline reading

**Example Query**:
```sql
SELECT mangaId, chapterTitle, chapterNumber,
       ROUND(sizeInBytes / 1024.0 / 1024.0, 2) as sizeInMB,
       datetime(downloadedAt/1000, 'unixepoch') as downloaded
FROM downloaded_chapters
ORDER BY downloadedAt DESC;
```

### Table 3: `saved_manga`
```sql
CREATE TABLE saved_manga (
  id TEXT PRIMARY KEY,
  uid TEXT,
  mangaId TEXT,
  title TEXT,
  coverImageUrl TEXT,
  lastChapterRead INTEGER,
  savedAt INTEGER,
  lastReadAt INTEGER,
  isFavorite INTEGER
);
```

**Purpose**: Local copy of saved manga for offline access

**Example Query**:
```sql
SELECT uid, title, lastChapterRead, isFavorite,
       datetime(savedAt/1000, 'unixepoch') as saved,
       datetime(lastReadAt/1000, 'unixepoch') as lastRead
FROM saved_manga
ORDER BY lastReadAt DESC;
```

---

## 🔧 Useful SQL Queries

### Get Cache Statistics
```sql
SELECT 
  COUNT(*) as total_entries,
  ROUND(SUM(LENGTH(value)) / 1024.0 / 1024.0, 2) as total_size_mb,
  COUNT(CASE WHEN expiresAt < strftime('%s', 'now') * 1000 THEN 1 END) as expired_entries
FROM cache_entries;
```

### Get Download Statistics
```sql
SELECT 
  COUNT(*) as total_chapters,
  COUNT(DISTINCT mangaId) as unique_manga,
  ROUND(SUM(sizeInBytes) / 1024.0 / 1024.0, 2) as total_size_mb
FROM downloaded_chapters;
```

### Get Saved Manga Statistics
```sql
SELECT 
  COUNT(*) as total_saved,
  COUNT(CASE WHEN isFavorite = 1 THEN 1 END) as total_favorites,
  AVG(lastChapterRead) as avg_chapters_read
FROM saved_manga;
```

### Find Expired Cache Entries
```sql
SELECT key, 
       datetime(expiresAt/1000, 'unixepoch') as expires
FROM cache_entries
WHERE expiresAt < strftime('%s', 'now') * 1000
ORDER BY expiresAt ASC;
```

### Get Largest Downloads
```sql
SELECT mangaId, chapterTitle, 
       ROUND(sizeInBytes / 1024.0 / 1024.0, 2) as sizeInMB
FROM downloaded_chapters
ORDER BY sizeInBytes DESC
LIMIT 10;
```

### Get Reading Progress
```sql
SELECT title, lastChapterRead, 
       datetime(lastReadAt/1000, 'unixepoch') as lastRead
FROM saved_manga
WHERE lastChapterRead > 0
ORDER BY lastReadAt DESC;
```

---

## 🛠️ Database Management

### Clear Expired Cache
```sql
DELETE FROM cache_entries 
WHERE expiresAt < strftime('%s', 'now') * 1000;
```

### Delete Specific Download
```sql
DELETE FROM downloaded_chapters 
WHERE chapterId = 'chapter_id_here';
```

### Remove Saved Manga
```sql
DELETE FROM saved_manga 
WHERE mangaId = 'manga_id_here';
```

### Clear All Cache
```sql
DELETE FROM cache_entries;
```

### Clear All Downloads
```sql
DELETE FROM downloaded_chapters;
```

### Reset Database
```sql
DELETE FROM cache_entries;
DELETE FROM downloaded_chapters;
DELETE FROM saved_manga;
```

---

## 📱 In-App Database Viewer (Future Feature)

You can add a debug screen to view the database in-app:

```dart
// Example: Add to SettingsScreen
import 'package:komikap/services/local_cache_service.dart';

class DatabaseDebugScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheService = LocalCacheService();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Database Debug')),
      body: FutureBuilder(
        future: Future.wait([
          cacheService.getTotalDownloadSize(),
          cacheService.getDownloadedChaptersByManga('all'),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Total Download Size: ${snapshot.data![0]} bytes'),
              Text('Downloaded Chapters: ${snapshot.data![1].length}'),
            ],
          );
        },
      ),
    );
  }
}
```

---

## 🔐 Security Notes

- **Database Location**: `/data/data/com.example.komikap/databases/`
- **Access**: Only accessible on rooted devices or via ADB
- **Encryption**: Consider adding SQLite encryption for sensitive data
- **Backup**: Database is backed up with app data

---

## 📊 Monitoring Database Size

### Check Database Size via ADB
```bash
adb shell du -sh /data/data/com.example.komikap/databases/
```

### Monitor Cache Growth
```sql
SELECT 
  COUNT(*) as entries,
  ROUND(SUM(LENGTH(value)) / 1024.0 / 1024.0, 2) as size_mb
FROM cache_entries;
```

---

## 🐛 Troubleshooting

### Database File Not Found
- Ensure app has been run at least once
- Check device is properly connected
- Verify package name: `com.example.komikap`

### Permission Denied
- Use `adb root` to get root access
- Or use Android Studio's Device File Explorer

### Database Locked
- Close the app
- Wait a few seconds
- Try again

### Corrupted Database
- Delete the database file
- App will recreate it on next run
- All cached data will be lost

---

## 📚 Related Documentation

- [SQLite Official Docs](https://www.sqlite.org/docs.html)
- [Flutter SQLite](https://pub.dev/packages/sqflite)
- [DB Browser for SQLite](https://sqlitebrowser.org/)

---

## ✅ Quick Checklist

- [ ] Downloaded `komikap_cache.db` from device
- [ ] Opened with SQLite viewer
- [ ] Checked `cache_entries` table
- [ ] Checked `downloaded_chapters` table
- [ ] Checked `saved_manga` table
- [ ] Ran test queries
- [ ] Verified data structure

---

**Database File**: `komikap_cache.db`
**Location**: `/data/data/com.example.komikap/databases/`
**Size**: Depends on cached data and downloads
**Auto-cleanup**: Expired cache entries are automatically deleted

Happy exploring! 🚀
