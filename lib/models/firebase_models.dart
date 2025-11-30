import 'package:cloud_firestore/cloud_firestore.dart';

// User Profile Model
class UserProfile {
  final String uid;
  final String username;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int followersCount;
  final int followingCount;

  UserProfile({
    required this.uid,
    required this.username,
    required this.email,
    this.profileImageUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
    );
  }
}

// Saved Manga Model
class SavedManga {
  final String id;
  final String uid;
  final String mangaId;
  final String title;
  final String? coverImageUrl;
  final int lastChapterRead;
  final DateTime savedAt;
  final DateTime lastReadAt;
  final bool isFavorite;

  SavedManga({
    required this.id,
    required this.uid,
    required this.mangaId,
    required this.title,
    this.coverImageUrl,
    this.lastChapterRead = 0,
    required this.savedAt,
    required this.lastReadAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'mangaId': mangaId,
      'title': title,
      'coverImageUrl': coverImageUrl,
      'lastChapterRead': lastChapterRead,
      'savedAt': savedAt,
      'lastReadAt': lastReadAt,
      'isFavorite': isFavorite,
    };
  }

  factory SavedManga.fromMap(Map<String, dynamic> map) {
    return SavedManga(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      mangaId: map['mangaId'] ?? '',
      title: map['title'] ?? '',
      coverImageUrl: map['coverImageUrl'],
      lastChapterRead: map['lastChapterRead'] ?? 0,
      savedAt: (map['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastReadAt: (map['lastReadAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}

// Post Model
class Post {
  final String id;
  final String uid;
  final String username;
  final String? userProfileImageUrl;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> likedBy;

  Post({
    required this.id,
    required this.uid,
    required this.username,
    this.userProfileImageUrl,
    required this.content,
    this.imageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.likedBy = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'username': username,
      'userProfileImageUrl': userProfileImageUrl,
      'content': content,
      'imageUrl': imageUrl,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'likedBy': likedBy,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      userProfileImageUrl: map['userProfileImageUrl'],
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: List<String>.from(map['likedBy'] ?? []),
    );
  }
}

// Comment Model
class Comment {
  final String id;
  final String postId;
  final String uid;
  final String username;
  final String? userProfileImageUrl;
  final String content;
  final int likesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> likedBy;

  Comment({
    required this.id,
    required this.postId,
    required this.uid,
    required this.username,
    this.userProfileImageUrl,
    required this.content,
    this.likesCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.likedBy = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'uid': uid,
      'username': username,
      'userProfileImageUrl': userProfileImageUrl,
      'content': content,
      'likesCount': likesCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'likedBy': likedBy,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      postId: map['postId'] ?? '',
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      userProfileImageUrl: map['userProfileImageUrl'],
      content: map['content'] ?? '',
      likesCount: map['likesCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: List<String>.from(map['likedBy'] ?? []),
    );
  }
}

// Downloaded Chapter Model (for local viewing)
class DownloadedChapter {
  final String id;
  final String mangaId;
  final String chapterId;
  final String chapterTitle;
  final int chapterNumber;
  final List<String> pageImagePaths; // Local file paths
  final DateTime downloadedAt;
  final int sizeInBytes;

  DownloadedChapter({
    required this.id,
    required this.mangaId,
    required this.chapterId,
    required this.chapterTitle,
    required this.chapterNumber,
    required this.pageImagePaths,
    required this.downloadedAt,
    required this.sizeInBytes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mangaId': mangaId,
      'chapterId': chapterId,
      'chapterTitle': chapterTitle,
      'chapterNumber': chapterNumber,
      'pageImagePaths': pageImagePaths,
      'downloadedAt': downloadedAt,
      'sizeInBytes': sizeInBytes,
    };
  }

  factory DownloadedChapter.fromMap(Map<String, dynamic> map) {
    return DownloadedChapter(
      id: map['id'] ?? '',
      mangaId: map['mangaId'] ?? '',
      chapterId: map['chapterId'] ?? '',
      chapterTitle: map['chapterTitle'] ?? '',
      chapterNumber: map['chapterNumber'] ?? 0,
      pageImagePaths: List<String>.from(map['pageImagePaths'] ?? []),
      downloadedAt: (map['downloadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sizeInBytes: map['sizeInBytes'] ?? 0,
    );
  }
}

// Cache Entry Model (for API response caching)
class CacheEntry {
  final String key;
  final String value; // JSON string
  final DateTime createdAt;
  final DateTime expiresAt;

  CacheEntry({
    required this.key,
    required this.value,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
    };
  }

  factory CacheEntry.fromMap(Map<String, dynamic> map) {
    return CacheEntry(
      key: map['key'] ?? '',
      value: map['value'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
