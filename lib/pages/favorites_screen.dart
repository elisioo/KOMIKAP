import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komikap/state/firebase_providers.dart';
import 'package:komikap/pages/comicdetailscreen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

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
          title: const Text(
            'Favorites',
            style: TextStyle(color: Colors.white54),
          ),
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
              title: const Text('Favorites',
                  style: TextStyle(color: Colors.white54)),
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
                    'Please login to view favorites',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        }

        final favoritesAsync = ref.watch(favoriteMangaProvider(user.uid));

        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          appBar: AppBar(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text('Favorites',
                  style: TextStyle(color: Colors.white54)),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  foregroundColor: Colors.white54,
                ),
              )),
          body: favoritesAsync.when(
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
            data: (favorites) {
              if (favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_outline,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No favorite manga yet',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add manga to favorites to see them here',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final manga = favorites[index];
                  return _buildFavoriteTile(context, manga, ref, user.uid);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFavoriteTile(
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Cover Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child:
                  manga.coverImageUrl != null && manga.coverImageUrl.isNotEmpty
                      ? Image.network(
                          manga.coverImageUrl,
                          width: 100,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 140,
                              color: Colors.grey[850],
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white54,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 100,
                          height: 140,
                          color: Colors.grey[850],
                          child: const Icon(
                            Icons.book_outlined,
                            color: Colors.white54,
                          ),
                        ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      manga.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Reading Progress
                    if (manga.lastChapterRead != null &&
                        manga.lastChapterRead > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chapter ${manga.lastChapterRead}',
                            style: const TextStyle(
                              color: Color(0xFFA855F7),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: (manga.lastChapterRead ?? 0) / 100,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFA855F7),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 8),

                    // Dates
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Favorited ${_formatDate(manga.savedAt)}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Read ${_formatDate(manga.lastReadAt)}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Remove Button
            Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  _showRemoveDialog(context, manga, ref, uid);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(
    BuildContext context,
    dynamic manga,
    WidgetRef ref,
    String uid,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Remove from Favorites?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove "${manga.title}" from favorites?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement remove from favorites
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Removed from favorites'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
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
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }
}
