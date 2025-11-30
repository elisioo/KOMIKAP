import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komikap/state/firebase_providers.dart';
import 'package:komikap/pages/comicdetailscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedMangaScreen extends ConsumerWidget {
  const SavedMangaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFA855F7)),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Saved Manga'),
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text('Saved Manga'),
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please login to view saved manga',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        }

        final savedMangaAsync = ref.watch(savedMangaProvider(user.uid));

        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text('Saved Manga',
                style: TextStyle(color: Colors.white54)),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(
                foregroundColor: Colors.white54,
              ),
            ),
          ),
          body: savedMangaAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFA855F7)),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            data: (savedManga) {
              if (savedManga.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_outline,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No saved manga yet',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start saving manga to see them here',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                itemCount: savedManga.length,
                itemBuilder: (context, index) {
                  final manga = savedManga[index];
                  return _buildMangaCard(context, manga, ref, user.uid);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMangaCard(
    BuildContext context,
    dynamic manga,
    WidgetRef ref,
    String uid,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComicDetailScreen(
              comic: {
                'id': manga.mangaId,
                'title': manga.title,
                'coverImageUrl': manga.coverImageUrl,
              },
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: manga.coverImageUrl != null &&
                            manga.coverImageUrl.isNotEmpty
                        ? Image.network(
                            manga.coverImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[850],
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white54,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[850],
                            child: const Icon(
                              Icons.book_outlined,
                              color: Colors.white54,
                            ),
                          ),
                  ),

                  // Favorite Badge
                  if (manga.isFavorite ?? false)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),

                  // Reading Progress
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (manga.lastChapterRead != null &&
                              manga.lastChapterRead > 0)
                            Text(
                              'Ch. ${manga.lastChapterRead}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: (manga.lastChapterRead ?? 0) / 100,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFA855F7),
                              ),
                              minHeight: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Title
          Text(
            manga.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          // Last Read Date
          Text(
            'Last read: ${_formatDate(manga.lastReadAt)}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }
}
