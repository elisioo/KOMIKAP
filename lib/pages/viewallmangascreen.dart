import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komikap/models/mangadexmanga.dart';
import 'package:komikap/pages/comicdetailscreen.dart';
import 'package:komikap/state/manga_providers.dart';

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

class ViewAllMangaScreen extends ConsumerStatefulWidget {
  final String category; // 'trending' or 'recent'
  final String title;

  const ViewAllMangaScreen({
    Key? key,
    required this.category,
    required this.title,
  }) : super(key: key);

  @override
  ConsumerState<ViewAllMangaScreen> createState() => _ViewAllMangaScreenState();
}

class _ViewAllMangaScreenState extends ConsumerState<ViewAllMangaScreen> {
  final ScrollController _scrollController = ScrollController();
  List<MangaDexManga> _allManga = [];
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore) {
        _loadMore();
      }
    }
  }

  void _loadMore() {
    setState(() => _isLoadingMore = true);
    ref.read(viewAllPageProvider.notifier).state++;
  }

  Widget _buildCoverImage(String coverUrl, {double? width, double? height}) {
    if (coverUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF2A2A2A), const Color(0xFF1F1F1F)],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.book_outlined,
            color: Colors.white54,
            size: width != null ? width * 0.3 : 40,
          ),
        ),
      );
    }

    return Image.network(
      coverUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[850],
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFFA855F7),
                strokeWidth: 2,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[850],
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: width != null ? width * 0.3 : 40,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mangaAsync = ref.watch(paginatedMangaProvider(widget.category));

    // Handle pagination data
    mangaAsync.whenData((newManga) {
      if (newManga.isNotEmpty && !_allManga.contains(newManga.first)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _allManga.addAll(newManga);
            _isLoadingMore = false;
          });
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Reset page when leaving
            ref.read(viewAllPageProvider.notifier).state = 0;
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey[400]),
            onPressed: () {
              // TODO: Add filter functionality
            },
          ),
        ],
      ),
      body: mangaAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFA855F7)),
              const SizedBox(height: 16),
              Text(
                'Loading ${widget.title.toLowerCase()}...',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 64),
              const SizedBox(height: 16),
              Text(
                'Error loading manga',
                style: TextStyle(color: Colors.red[400], fontSize: 18),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(paginatedMangaProvider(widget.category));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA855F7),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (initialManga) {
          // Use _allManga if we have pagination data, otherwise use initial
          final displayManga = _allManga.isEmpty ? initialManga : _allManga;

          if (displayManga.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, color: Colors.grey[600], size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No manga found',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: displayManga.length + (_isLoadingMore ? 2 : 0),
            itemBuilder: (context, index) {
              // Show loading indicators at the bottom
              if (index >= displayManga.length) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFA855F7),
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              final manga = displayManga[index];
              final coverUrl = manga.getCoverUrl();

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComicDetailScreen(
                        comic: {
                          'id': manga.id,
                          'mangaId': manga.id,
                          'title': manga.title,
                          'author': manga.authors.isNotEmpty
                              ? manga.authors.join(', ')
                              : 'Unknown Author',
                          'artist': manga.artists.isNotEmpty
                              ? manga.artists.join(', ')
                              : 'Unknown Artist',
                          'coverUrl': coverUrl,
                          'synopsis':
                              manga.description ?? 'No description available.',
                          'description':
                              manga.description ?? 'No description available.',
                          'status': manga.status,
                          'tags': manga.tags,
                          'genres': manga.tags.take(5).toList(),
                          'rating': 0.0,
                          'chapters': 0,
                          'source': 'MangaDex',
                          'ageRating': _getAgeRating(manga.tags),
                          'createdAt': manga.createdAt?.toString() ?? '',
                          'updatedAt': manga.updatedAt?.toString() ?? '',
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2A2A2A),
                        const Color(0xFF1F1F1F),
                      ],
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cover image
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: _buildCoverImage(
                            coverUrl,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      // Info section
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              manga.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: manga.status == 'ongoing'
                                        ? Colors.green[700]
                                        : Colors.blue[700],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    manga.status.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    manga.authors.isNotEmpty
                                        ? manga.authors.first
                                        : 'Unknown',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper method to determine age rating based on tags
  String _getAgeRating(List<String> tags) {
    final matureTags = ['gore', 'sexual violence', 'erotica', 'smut'];
    final suggestiveTags = ['ecchi', 'suggestive', 'sexual content'];

    for (var tag in tags) {
      final lowerTag = tag.toLowerCase();
      if (matureTags.any((mature) => lowerTag.contains(mature))) {
        return '+18';
      }
      if (suggestiveTags.any((suggestive) => lowerTag.contains(suggestive))) {
        return '+16';
      }
    }
    return '+13';
  }
}
