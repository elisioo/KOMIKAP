import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komikap/state/firebase_providers.dart';
import 'package:komikap/services/local_cache_service.dart';
import 'package:komikap/pages/readerscreen.dart';
import 'package:komikap/pages/comicdetailscreen.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  @override
  Widget build(BuildContext context) {
    final totalSizeAsync = ref.watch(totalDownloadSizeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Downloads',
          style: TextStyle(color: Colors.white54),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            foregroundColor: Colors.white54,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: () {
              // Refresh the total size
              ref.invalidate(totalDownloadSizeProvider);
            },
          ),
          totalSizeAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFA855F7),
                ),
              ),
            ),
            error: (error, stack) => const SizedBox.shrink(),
            data: (size) => Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  _formatBytes(size),
                  style: const TextStyle(
                    color: Color(0xFFA855F7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildDownloadsList(context),
    );
  }

  Widget _buildDownloadsList(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _getAllDownloadedChapters(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFA855F7)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white54),
            ),
          );
        }

        final chapters = snapshot.data ?? [];

        if (chapters.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_outlined,
                  size: 64,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Downloaded Chapters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Download chapters to read offline',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[800]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'How to Download',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Open a manga\n2. Go to a chapter\n3. Tap the download icon\n4. Chapter will be saved locally',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Group chapters by manga
        final Map<String, List<dynamic>> groupedByManga = {};
        for (var chapter in chapters) {
          final mangaId = chapter['mangaId'] as String;
          groupedByManga.putIfAbsent(mangaId, () => []).add(chapter);
        }

        // Get manga titles from saved_manga table
        return FutureBuilder<Map<String, String>>(
          future: _getMangaTitles(groupedByManga.keys.toList()),
          builder: (context, mangaTitlesSnapshot) {
            if (mangaTitlesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFA855F7)),
              );
            }

            final mangaTitles = mangaTitlesSnapshot.data ?? {};

            // Display chapters organized by manga
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedByManga.length,
              itemBuilder: (context, mangaIndex) {
                final mangaId = groupedByManga.keys.elementAt(mangaIndex);
                final mangaChapters = groupedByManga[mangaId]!;
                final mangaTitle = mangaTitles[mangaId] ?? 'Unknown Manga';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Manga Title Header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, top: 8),
                      child: Text(
                        mangaTitle,
                        style: const TextStyle(
                          color: Color(0xFFA855F7),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Chapters for this manga
                    ...mangaChapters.map((chapter) {
                      final chapterTitle = chapter['chapterTitle'] as String;
                      final chapterNumber = chapter['chapterNumber'] as int;
                      final chapterId = chapter['chapterId'] as String;
                      final pageImagePaths =
                          (chapter['pageImagePaths'] as String).split('|');
                      final size = chapter['sizeInBytes'] as int;
                      final downloadedAt = DateTime.fromMillisecondsSinceEpoch(
                          chapter['downloadedAt'] as int);

                      return GestureDetector(
                        onTap: () {
                          // Open reader screen with offline pages
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReaderScreen(
                                comic: {
                                  'title': chapterTitle,
                                  'pages': pageImagePaths,
                                },
                                chapterId: chapterId,
                                chapter: chapterNumber,
                                mangaId: mangaId,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // First page thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: pageImagePaths.isNotEmpty &&
                                          pageImagePaths[0].isNotEmpty
                                      ? Image.network(
                                          pageImagePaths[0],
                                          width: 70,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              width: 70,
                                              height: 100,
                                              color: Colors.grey[800],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: 70,
                                          height: 100,
                                          color: Colors.grey[800],
                                          child: const Icon(
                                            Icons.image_outlined,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                // Chapter info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Chapter $chapterNumber',
                                        style: const TextStyle(
                                          color: Color(0xFFA855F7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        chapterTitle,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.image_outlined,
                                            size: 14,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${pageImagePaths.length} pages',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.storage,
                                            size: 14,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatBytes(size),
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Downloaded ${_formatDate(downloadedAt)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Delete button
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    final cacheService =
                                        LocalCacheService();
                                    await cacheService
                                        .deleteDownloadedChapter(chapterId);
                                    // Refresh the UI
                                    (context as Element).markNeedsBuild();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _getAllDownloadedChapters() async {
    final cacheService = LocalCacheService();
    final db = await cacheService.database;

    try {
      final results = await db.query(
        'downloaded_chapters',
        orderBy: 'downloadedAt DESC',
      );
      return results;
    } catch (e) {
      print('Error fetching downloaded chapters: $e');
      return [];
    }
  }

  Future<Map<String, String>> _getMangaTitles(List<String> mangaIds) async {
    final cacheService = LocalCacheService();
    final db = await cacheService.database;
    final mangaTitles = <String, String>{};

    try {
      for (var mangaId in mangaIds) {
        final results = await db.query(
          'saved_manga',
          where: 'mangaId = ?',
          whereArgs: [mangaId],
          limit: 1,
        );

        if (results.isNotEmpty) {
          mangaTitles[mangaId] = results.first['title'] as String;
        } else {
          mangaTitles[mangaId] = 'Manga $mangaId';
        }
      }
    } catch (e) {
      print('Error fetching manga titles: $e');
      // Return default titles if error
      for (var mangaId in mangaIds) {
        mangaTitles[mangaId] = 'Manga $mangaId';
      }
    }

    return mangaTitles;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }


  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
