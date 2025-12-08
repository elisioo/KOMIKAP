import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../services/local_cache_service.dart';
import '../models/firebase_models.dart';

// Theme Provider
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void setThemeFromString(String themeLabel) {
    switch (themeLabel) {
      case 'Light':
        state = ThemeMode.light;
        break;
      case 'Dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier());

// Firebase Service Provider
final firebaseServiceProvider = Provider((ref) => FirebaseService());

// Local Cache Service Provider
final localCacheServiceProvider = Provider((ref) => LocalCacheService());

// Current User Provider
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Auth State Provider (alias for currentUserProvider)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// User Profile Provider
final userProfileProvider = FutureProvider.family<UserProfile?, String>((ref, uid) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getUserProfile(uid);
});

final isFollowingUserProvider =
    FutureProvider.family<bool, String>((ref, targetUid) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null || currentUser.uid == targetUid) {
    return false;
  }
  return firebaseService.isFollowingUser(currentUser.uid, targetUid);
});

// Saved Manga Provider
final savedMangaProvider = FutureProvider.family<List<SavedManga>, String>((ref, uid) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getSavedManga(uid);
});

// Favorite Manga Provider
final favoriteMangaProvider = FutureProvider.family<List<SavedManga>, String>((ref, uid) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getFavoriteManga(uid);
});

// Posts Provider
final postsProvider = FutureProvider<List<Post>>((ref) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getPosts();
});

// User Posts Provider
final userPostsProvider = FutureProvider.family<List<Post>, String>((ref, uid) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getUserPosts(uid);
});

// Comments Provider
final commentsProvider = FutureProvider.family<List<Comment>, String>((ref, postId) async {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getComments(postId);
});

// Downloaded Chapters Provider
final downloadedChaptersProvider =
    FutureProvider.family<List<DownloadedChapter>, String>((ref, mangaId) async {
  final cacheService = ref.watch(localCacheServiceProvider);
  return cacheService.getDownloadedChaptersByManga(mangaId);
});

// Total Download Size Provider
final totalDownloadSizeProvider = FutureProvider<int>((ref) async {
  final cacheService = ref.watch(localCacheServiceProvider);
  return cacheService.getTotalDownloadSize();
});

// Specific Downloaded Chapter Provider
final downloadedChapterProvider =
    FutureProvider.family<DownloadedChapter?, String>((ref, chapterId) async {
  final cacheService = ref.watch(localCacheServiceProvider);
  return cacheService.getDownloadedChapter(chapterId);
});

// Auth State Notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final FirebaseService _firebaseService;

  AuthNotifier(this._firebaseService) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      state = AsyncValue.data(user);
    }, onError: (error) {
      state = AsyncValue.error(error, StackTrace.current);
    });
  }

  Future<void> logout() async {
    await _firebaseService.logoutUser();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return AuthNotifier(firebaseService);
});

// Saved Manga Notifier for mutations
class SavedMangaNotifier extends StateNotifier<AsyncValue<List<SavedManga>>> {
  final FirebaseService _firebaseService;
  final String _uid;

  SavedMangaNotifier(this._firebaseService, this._uid) : super(const AsyncValue.loading()) {
    _loadSavedManga();
  }

  Future<void> _loadSavedManga() async {
    try {
      final manga = await _firebaseService.getSavedManga(_uid);
      state = AsyncValue.data(manga);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveManga({
    required String mangaId,
    required String title,
    String? coverImageUrl,
  }) async {
    try {
      await _firebaseService.saveManga(
        uid: _uid,
        mangaId: mangaId,
        title: title,
        coverImageUrl: coverImageUrl,
      );
      await _loadSavedManga();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeSavedManga(String mangaId) async {
    try {
      await _firebaseService.removeSavedManga(_uid, mangaId);
      await _loadSavedManga();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(String mangaId, bool isFavorite) async {
    try {
      await _firebaseService.toggleFavoriteManga(_uid, mangaId, isFavorite);
      await _loadSavedManga();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final savedMangaNotifierProvider =
    StateNotifierProvider.family<SavedMangaNotifier, AsyncValue<List<SavedManga>>, String>(
        (ref, uid) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return SavedMangaNotifier(firebaseService, uid);
});

// Posts Notifier for mutations
class PostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final FirebaseService _firebaseService;

  PostsNotifier(this._firebaseService) : super(const AsyncValue.loading()) {
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await _firebaseService.getPosts();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createPost({
    required String uid,
    required String username,
    required String content,
    String? imageUrl,
  }) async {
    try {
      await _firebaseService.createPost(
        uid: uid,
        username: username,
        content: content,
        imageUrl: imageUrl,
      );
      await _loadPosts();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firebaseService.deletePost(postId);
      await _loadPosts();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> likePost(String postId, String uid) async {
    try {
      await _firebaseService.likePost(postId, uid);
      await _loadPosts();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unlikePost(String postId, String uid) async {
    try {
      await _firebaseService.unlikePost(postId, uid);
      await _loadPosts();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final postsNotifierProvider = StateNotifierProvider<PostsNotifier, AsyncValue<List<Post>>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return PostsNotifier(firebaseService);
});

// Comments Notifier for mutations
class CommentsNotifier extends StateNotifier<AsyncValue<List<Comment>>> {
  final FirebaseService _firebaseService;
  final String _postId;

  CommentsNotifier(this._firebaseService, this._postId) : super(const AsyncValue.loading()) {
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _firebaseService.getComments(_postId);
      state = AsyncValue.data(comments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addComment({
    required String uid,
    required String username,
    required String content,
  }) async {
    try {
      await _firebaseService.addComment(
        postId: _postId,
        uid: uid,
        username: username,
        content: content,
      );
      await _loadComments();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _firebaseService.deleteComment(_postId, commentId);
      await _loadComments();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> likeComment(String commentId, String uid) async {
    try {
      await _firebaseService.likeComment(_postId, commentId, uid);
      await _loadComments();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unlikeComment(String commentId, String uid) async {
    try {
      await _firebaseService.unlikeComment(_postId, commentId, uid);
      await _loadComments();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final commentsNotifierProvider =
    StateNotifierProvider.family<CommentsNotifier, AsyncValue<List<Comment>>, String>(
        (ref, postId) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return CommentsNotifier(firebaseService, postId);
});
