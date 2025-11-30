import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:komikap/models/mangadexmanga.dart';

class MangaDexService {
  static const String baseUrl = 'https://api.mangadex.org';
  static const int limit = 20;

  final http.Client _client;

  MangaDexService() : _client = http.Client();

  /// Make a request to MangaDex API
  Future<http.Response> _makeRequest(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: {'User-Agent': 'komikap/1.0'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Request failed: $e');
      rethrow;
    }
  }

  /// Search manga by title
  Future<List<MangaDexManga>> searchManga(
    String query, {
    int offset = 0,
    int? limit,
    List<String>? includedTags,
    List<String>? excludedTags,
    String? contentRating,
  }) async {
    try {
      final params = <String, dynamic>{
        'title': query,
        'limit': (limit ?? MangaDexService.limit).toString(),
        'offset': offset.toString(),
        'includes[]': 'cover_art',
        'order[relevance]': 'desc',
      };

      if (includedTags != null && includedTags.isNotEmpty) {
        params['includedTags[]'] = includedTags;
      }

      if (excludedTags != null && excludedTags.isNotEmpty) {
        params['excludedTags[]'] = excludedTags;
      }

      if (contentRating != null) {
        params['contentRating[]'] = contentRating;
      }

      final uri = Uri.https('api.mangadex.org', '/manga', params);
      final response = await _makeRequest(uri);

      final json = jsonDecode(response.body);
      final data = json['data'] as List<dynamic>;
      return data.map((item) => MangaDexManga.fromJson(item)).toList();
    } catch (e) {
      print('Error searching manga: $e');
      return [];
    }
  }

  /// Get popular manga (sorted by follows)
  Future<List<MangaDexManga>> getPopularManga({
    int offset = 0,
    int? limit,
  }) async {
    try {
      final params = {
        'limit': (limit ?? MangaDexService.limit).toString(),
        'offset': offset.toString(),
        'includes[]': 'cover_art',
        'order[followedCount]': 'desc',
        'contentRating[]': ['safe', 'suggestive'],
      };

      final uri = Uri.https('api.mangadex.org', '/manga', params);
      final response = await _makeRequest(uri);

      final json = jsonDecode(response.body);
      final data = json['data'] as List<dynamic>;
      return data.map((item) => MangaDexManga.fromJson(item)).toList();
    } catch (e) {
      print('Error getting popular manga: $e');
      return [];
    }
  }

  /// Get recently updated manga
  Future<List<MangaDexManga>> getRecentlyUpdated({
    int offset = 0,
    int? limit,
  }) async {
    try {
      final params = {
        'limit': (limit ?? MangaDexService.limit).toString(),
        'offset': offset.toString(),
        'includes[]': 'cover_art',
        'order[updatedAt]': 'desc',
        'contentRating[]': ['safe', 'suggestive'],
      };

      final uri = Uri.https('api.mangadex.org', '/manga', params);
      final response = await _makeRequest(uri);

      final json = jsonDecode(response.body);
      final data = json['data'] as List<dynamic>;
      return data.map((item) => MangaDexManga.fromJson(item)).toList();
    } catch (e) {
      print('Error getting recent manga: $e');
      return [];
    }
  }

  /// Get manga by ID with full details
  Future<MangaDexManga?> getMangaById(String mangaId) async {
    try {
      final params = {
        'includes[]': ['cover_art', 'author', 'artist'],
      };

      final uri = Uri.https('api.mangadex.org', '/manga/$mangaId', params);
      final response = await _makeRequest(uri);

      final json = jsonDecode(response.body);
      return MangaDexManga.fromJson(json['data']);
    } catch (e) {
      print('Error getting manga: $e');
      return null;
    }
  }

  /// Get chapters for a manga
  Future<List<MangaDexChapter>> getMangaChapters(
    String mangaId, {
    int offset = 0,
    int? limit,
    String translatedLanguage = 'en',
  }) async {
    try {
      final params = {
        'manga': mangaId,
        'limit': (limit ?? 100).toString(),
        'offset': offset.toString(),
        'translatedLanguage[]': translatedLanguage,
        'includes[]': 'scanlation_group',
        'order[chapter]': 'asc',
        'order[volume]': 'asc',
      };

      final uri = Uri.https('api.mangadex.org', '/chapter', params);
      final response = await _makeRequest(uri);

      final json = jsonDecode(response.body);
      final data = json['data'] as List<dynamic>;
      return data.map((item) => MangaDexChapter.fromJson(item)).toList();
    } catch (e) {
      print('Error getting chapters: $e');
      return [];
    }
  }

  /// Get chapter pages (images)
  Future<MangaDexPageData?> getChapterPages(String chapterId) async {
    try {
      final uri = Uri.https('api.mangadex.org', '/at-home/server/$chapterId');
      final response = await _makeRequest(uri);

      final json = jsonDecode(response.body);
      return MangaDexPageData.fromJson(json);
    } catch (e) {
      print('Error getting chapter pages: $e');
      return null;
    }
  }

  /// Get manga by tags
  Future<List<MangaDexManga>> getMangaByTags(
    List<String> tagIds, {
    int offset = 0,
    int? limit,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': (limit ?? MangaDexService.limit).toString(),
        'offset': offset.toString(),
        'includes[]': 'cover_art',
        'order[followedCount]': 'desc',
        'includedTags[]': tagIds,
      };

      final uri = Uri.https('api.mangadex.org', '/manga', params);
      final response = await _makeRequest(uri);

      final json = jsonDecode(response.body);
      final data = json['data'] as List<dynamic>;
      return data.map((item) => MangaDexManga.fromJson(item)).toList();
    } catch (e) {
      print('Error getting manga by tags: $e');
      return [];
    }
  }

  /// Get random manga
  Future<MangaDexManga?> getRandomManga() async {
    try {
      final params = {
        'includes[]': ['cover_art', 'author', 'artist'],
        'contentRating[]': ['safe', 'suggestive'],
      };

      final uri = Uri.https('api.mangadex.org', '/manga/random', params);
      final response = await _makeRequest(uri);

      final json = jsonDecode(response.body);
      return MangaDexManga.fromJson(json['data']);
    } catch (e) {
      print('Error getting random manga: $e');
      return null;
    }
  }

  /// Get available tags
  Future<List<Map<String, dynamic>>> getTags() async {
    try {
      final uri = Uri.https('api.mangadex.org', '/manga/tag');
      final response = await _makeRequest(uri);

      final json = jsonDecode(response.body);
      final data = json['data'] as List<dynamic>;
      return data.map((item) {
        return {
          'id': item['id'] as String,
          'name': (item['attributes']['name']['en'] ?? 'Unknown') as String,
          'group': item['attributes']['group'] as String? ?? 'theme',
        };
      }).toList();
    } catch (e) {
      print('Error getting tags: $e');
      return [];
    }
  }

  void dispose() {
    _client.close();
  }
}
