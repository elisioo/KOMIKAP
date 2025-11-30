import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;
import '../models/firebase_models.dart';

// Check if running on web
bool _isWeb() {
  try {
    return io.Platform.isAndroid == false &&
        io.Platform.isIOS == false &&
        io.Platform.isWindows == false &&
        io.Platform.isLinux == false &&
        io.Platform.isMacOS == false;
  } catch (e) {
    // If Platform check fails, assume web
    return true;
  }
}

class LocalCacheService {
  static final LocalCacheService _instance = LocalCacheService._internal();
  static Database? _database;
  static bool _isInitializing = false;
  static final bool _isWebPlatform = _isWeb();

  factory LocalCacheService() {
    return _instance;
  }

  LocalCacheService._internal();

  Future<Database> get database async {
    // On web, return a dummy database (operations will be no-ops)
    if (_isWebPlatform) {
      print('⚠️ Web platform detected - SQLite operations disabled');
      throw Exception('SQLite not available on web platform');
    }

    if (_database != null) {
      return _database!;
    }

    if (_isInitializing) {
      // Wait for initialization to complete
      int attempts = 0;
      while (_database == null && attempts < 100) {
        await Future.delayed(const Duration(milliseconds: 50));
        attempts++;
      }
      if (_database != null) return _database!;
    }

    _isInitializing = true;
    try {
      _database = await _initDatabase();
    } finally {
      _isInitializing = false;
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path;

      try {
        if (io.Platform.isAndroid || io.Platform.isIOS) {
          // Mobile: Use standard databases path
          final databasesPath = await getDatabasesPath();
          path = join(databasesPath, 'komikap_cache.db');
          print('📱 Mobile database path: $path');
        } else {
          // Desktop: Use application documents directory
          // Note: path_provider is not used here to avoid web issues
          path = 'komikap_cache.db';
          print('🖥️ Desktop database path: $path');
        }
      } catch (e) {
        print('❌ Platform detection failed: $e');
        throw Exception('Cannot initialize database on this platform');
      }

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createTables,
        onOpen: (db) {
          print('✅ Database opened successfully');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // Handle database upgrades if needed
        },
      );
    } catch (e) {
      print('❌ Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _createTables(Database db, int version) async {
    print('Creating database tables...');

    // Cache table for API responses
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cache_entries (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        expiresAt INTEGER NOT NULL
      )
    ''');

    // Downloaded chapters table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS downloaded_chapters (
        id TEXT PRIMARY KEY,
        mangaId TEXT NOT NULL,
        chapterId TEXT NOT NULL,
        chapterTitle TEXT NOT NULL,
        chapterNumber INTEGER NOT NULL,
        pageImagePaths TEXT NOT NULL,
        downloadedAt INTEGER NOT NULL,
        sizeInBytes INTEGER NOT NULL
      )
    ''');

    // Saved manga table (local copy)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_manga (
        id TEXT PRIMARY KEY,
        uid TEXT NOT NULL,
        mangaId TEXT NOT NULL,
        title TEXT NOT NULL,
        coverImageUrl TEXT,
        lastChapterRead INTEGER NOT NULL,
        savedAt INTEGER NOT NULL,
        lastReadAt INTEGER NOT NULL,
        isFavorite INTEGER NOT NULL
      )
    ''');

    // Create indexes for faster queries
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_cache_expiresAt ON cache_entries(expiresAt)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_downloaded_mangaId ON downloaded_chapters(mangaId)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_saved_uid ON saved_manga(uid)');

    print('Database tables created successfully');
  }

  // Cache operations
  Future<void> cacheData(String key, String value,
      {Duration ttl = const Duration(hours: 24)}) async {
    try {
      if (_isWebPlatform) {
        print('⚠️ Skipping cache on web platform');
        return;
      }
      
      final db = await database;
      final now = DateTime.now();
      final expiresAt = now.add(ttl);

      await db.insert(
        'cache_entries',
        {
          'key': key,
          'value': value,
          'createdAt': now.millisecondsSinceEpoch,
          'expiresAt': expiresAt.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('⚠️ Error caching data: $e');
      // Don't rethrow on web - just log
    }
  }

  Future<String?> getCachedData(String key) async {
    try {
      if (_isWebPlatform) {
        return null; // No cache on web
      }
      
      final db = await database;
      final result = await db.query(
        'cache_entries',
        where: 'key = ?',
        whereArgs: [key],
      );

      if (result.isEmpty) return null;

      final entry = result.first;
      final expiresAt =
          DateTime.fromMillisecondsSinceEpoch(entry['expiresAt'] as int);

      if (DateTime.now().isAfter(expiresAt)) {
        await db.delete('cache_entries', where: 'key = ?', whereArgs: [key]);
        return null;
      }

      return entry['value'] as String;
    } catch (e) {
      print('⚠️ Error getting cached data: $e');
      return null;
    }
  }

  Future<void> clearExpiredCache() async {
    try {
      if (_isWebPlatform) return;
      
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;
      await db
          .delete('cache_entries', where: 'expiresAt < ?', whereArgs: [now]);
    } catch (e) {
      print('⚠️ Error clearing expired cache: $e');
    }
  }

  // Downloaded chapters operations
  Future<void> saveDownloadedChapter(DownloadedChapter chapter) async {
    try {
      if (_isWebPlatform) {
        print('⚠️ Skipping download save on web platform');
        return;
      }
      
      print('Saving chapter to database: ${chapter.chapterTitle}');
      final db = await database;
      await db.insert(
        'downloaded_chapters',
        {
          'id': chapter.id,
          'mangaId': chapter.mangaId,
          'chapterId': chapter.chapterId,
          'chapterTitle': chapter.chapterTitle,
          'chapterNumber': chapter.chapterNumber,
          'pageImagePaths': chapter.pageImagePaths.join('|'),
          'downloadedAt': chapter.downloadedAt.millisecondsSinceEpoch,
          'sizeInBytes': chapter.sizeInBytes,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ Chapter saved successfully');
    } catch (e) {
      print('❌ Error saving downloaded chapter: $e');
      // Don't rethrow on web
    }
  }

  Future<DownloadedChapter?> getDownloadedChapter(String chapterId) async {
    try {
      if (_isWebPlatform) return null;
      
      final db = await database;
      final result = await db.query(
        'downloaded_chapters',
        where: 'chapterId = ?',
        whereArgs: [chapterId],
      );

      if (result.isEmpty) return null;

      final row = result.first;
      return DownloadedChapter(
        id: row['id'] as String,
        mangaId: row['mangaId'] as String,
        chapterId: row['chapterId'] as String,
        chapterTitle: row['chapterTitle'] as String,
        chapterNumber: row['chapterNumber'] as int,
        pageImagePaths: (row['pageImagePaths'] as String).split('|'),
        downloadedAt:
            DateTime.fromMillisecondsSinceEpoch(row['downloadedAt'] as int),
        sizeInBytes: row['sizeInBytes'] as int,
      );
    } catch (e) {
      print('⚠️ Error getting downloaded chapter: $e');
      return null;
    }
  }

  Future<List<DownloadedChapter>> getDownloadedChaptersByManga(
      String mangaId) async {
    try {
      if (_isWebPlatform) return [];
      
      final db = await database;
      final results = await db.query(
        'downloaded_chapters',
        where: 'mangaId = ?',
        whereArgs: [mangaId],
        orderBy: 'chapterNumber DESC',
      );

      return results.map((row) {
        return DownloadedChapter(
          id: row['id'] as String,
          mangaId: row['mangaId'] as String,
          chapterId: row['chapterId'] as String,
          chapterTitle: row['chapterTitle'] as String,
          chapterNumber: row['chapterNumber'] as int,
          pageImagePaths: (row['pageImagePaths'] as String).split('|'),
          downloadedAt:
              DateTime.fromMillisecondsSinceEpoch(row['downloadedAt'] as int),
          sizeInBytes: row['sizeInBytes'] as int,
        );
      }).toList();
    } catch (e) {
      print('⚠️ Error getting downloaded chapters: $e');
      return [];
    }
  }

  Future<void> deleteDownloadedChapter(String chapterId) async {
    try {
      if (_isWebPlatform) return;
      
      final db = await database;
      await db.delete(
        'downloaded_chapters',
        where: 'chapterId = ?',
        whereArgs: [chapterId],
      );
    } catch (e) {
      print('⚠️ Error deleting downloaded chapter: $e');
    }
  }

  Future<int> getTotalDownloadSize() async {
    try {
      if (_isWebPlatform) return 0;
      
      final db = await database;
      final result = await db.rawQuery(
          'SELECT SUM(sizeInBytes) as total FROM downloaded_chapters');
      return (result.first['total'] as int?) ?? 0;
    } catch (e) {
      print('⚠️ Error getting total download size: $e');
      return 0;
    }
  }

  // Saved manga operations (local copy)
  Future<void> saveMangaLocally(SavedManga manga) async {
    try {
      if (_isWebPlatform) {
        print('⚠️ Skipping local manga save on web platform');
        return;
      }
      
      final db = await database;
      await db.insert(
        'saved_manga',
        {
          'id': manga.id,
          'uid': manga.uid,
          'mangaId': manga.mangaId,
          'title': manga.title,
          'coverImageUrl': manga.coverImageUrl,
          'lastChapterRead': manga.lastChapterRead,
          'savedAt': manga.savedAt.millisecondsSinceEpoch,
          'lastReadAt': manga.lastReadAt.millisecondsSinceEpoch,
          'isFavorite': manga.isFavorite ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('⚠️ Error saving manga locally: $e');
      // Don't rethrow on web
    }
  }

  Future<SavedManga?> getSavedMangaLocally(String mangaId) async {
    try {
      if (_isWebPlatform) return null;
      
      final db = await database;
      final result = await db.query(
        'saved_manga',
        where: 'mangaId = ?',
        whereArgs: [mangaId],
      );

      if (result.isEmpty) return null;

      final row = result.first;
      return SavedManga(
        id: row['id'] as String,
        uid: row['uid'] as String,
        mangaId: row['mangaId'] as String,
        title: row['title'] as String,
        coverImageUrl: row['coverImageUrl'] as String?,
        lastChapterRead: row['lastChapterRead'] as int,
        savedAt: DateTime.fromMillisecondsSinceEpoch(row['savedAt'] as int),
        lastReadAt:
            DateTime.fromMillisecondsSinceEpoch(row['lastReadAt'] as int),
        isFavorite: (row['isFavorite'] as int) == 1,
      );
    } catch (e) {
      print('⚠️ Error getting saved manga locally: $e');
      return null;
    }
  }

  Future<List<SavedManga>> getAllSavedMangaLocally(String uid) async {
    try {
      if (_isWebPlatform) return [];
      
      final db = await database;
      final results = await db.query(
        'saved_manga',
        where: 'uid = ?',
        whereArgs: [uid],
        orderBy: 'lastReadAt DESC',
      );

      return results.map((row) {
        return SavedManga(
          id: row['id'] as String,
          uid: row['uid'] as String,
          mangaId: row['mangaId'] as String,
          title: row['title'] as String,
          coverImageUrl: row['coverImageUrl'] as String?,
          lastChapterRead: row['lastChapterRead'] as int,
          savedAt: DateTime.fromMillisecondsSinceEpoch(row['savedAt'] as int),
          lastReadAt:
              DateTime.fromMillisecondsSinceEpoch(row['lastReadAt'] as int),
          isFavorite: (row['isFavorite'] as int) == 1,
        );
      }).toList();
    } catch (e) {
      print('⚠️ Error getting all saved manga locally: $e');
      return [];
    }
  }

  Future<void> clearAllData() async {
    try {
      if (_isWebPlatform) return;
      
      final db = await database;
      await db.delete('cache_entries');
      await db.delete('downloaded_chapters');
      await db.delete('saved_manga');
    } catch (e) {
      print('⚠️ Error clearing all data: $e');
    }
  }
}
