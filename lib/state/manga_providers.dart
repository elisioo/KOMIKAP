import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komikap/models/mangadexmanga.dart';
import 'package:komikap/services/api/mangadexapiservice.dart';

// Initialize MangaDex service
final mangaDexServiceProvider = Provider<MangaDexService>((ref) {
  return MangaDexService();
});

// Get chapters for a specific manga
final mangaChaptersProvider =
    FutureProvider.family<List<MangaDexChapter>, String>((ref, mangaId) async {
      final service = ref.watch(mangaDexServiceProvider);
      return service.getMangaChapters(mangaId);
    });

// Get pages for a specific chapter
final chapterPagesProvider = FutureProvider.family<MangaDexPageData?, String>((
  ref,
  chapterId,
) async {
  final service = ref.watch(mangaDexServiceProvider);
  return service.getChapterPages(chapterId);
});

// Get chapter page URLs
final chapterPageUrlsProvider = FutureProvider.family<List<String>, String>((
  ref,
  chapterId,
) async {
  final pageData = await ref.watch(chapterPagesProvider(chapterId).future);
  if (pageData == null) return [];
  return pageData.getPageUrls();
});

// Get manga details by ID
final mangaDetailsProvider = FutureProvider.family<MangaDexManga?, String>((
  ref,
  mangaId,
) async {
  final service = ref.watch(mangaDexServiceProvider);
  return service.getMangaById(mangaId);
});

// ===== LIBRARY SCREEN PROVIDERS =====

// Trending manga for home screen
final trendingMangaProvider = FutureProvider<List<MangaDexManga>>((ref) async {
  final service = ref.watch(mangaDexServiceProvider);
  return service.getPopularManga(limit: 6);
});

// Recently updated manga for home screen
final recentlyUpdatedMangaProvider = FutureProvider<List<MangaDexManga>>((
  ref,
) async {
  final service = ref.watch(mangaDexServiceProvider);
  return service.getRecentlyUpdated(limit: 5);
});

// Continue reading list (local storage simulation)
final continueReadingProvider = StateProvider<List<Map<String, dynamic>>>((
  ref,
) {
  return [
    {
      'id': 'continue-1',
      'title': 'Your Last Read Manga',
      'author': 'Will appear here',
      'chapter': 'Chapter 0',
      'progress': 0.0,
      'rating': 0.0,
      'chapters': 0,
      'coverUrl': '',
    },
  ];
});

// ===== VIEW ALL SCREEN PROVIDERS =====

// State provider for pagination
final viewAllPageProvider = StateProvider<int>((ref) => 0);

// Provider for paginated manga list
final paginatedMangaProvider =
    FutureProvider.family<List<MangaDexManga>, String>((ref, category) async {
      final service = ref.watch(mangaDexServiceProvider);
      final page = ref.watch(viewAllPageProvider);
      final offset = page * 20;

      switch (category) {
        case 'trending':
          return service.getPopularManga(limit: 20, offset: offset);
        case 'recent':
          return service.getRecentlyUpdated(limit: 20, offset: offset);
        default:
          return service.getPopularManga(limit: 20, offset: offset);
      }
    });
