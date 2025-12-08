import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komikap/pages/comicdetailscreen.dart';
import 'package:komikap/state/manga_providers.dart';
import 'package:komikap/models/mangadexmanga.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final selectedGenreProvider = StateProvider<String>((ref) => 'All');

final searchResultsProvider = FutureProvider.autoDispose<List<MangaDexManga>>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider);
  final selectedGenre = ref.watch(selectedGenreProvider);
  final service = ref.watch(mangaDexServiceProvider);

  if (query.isEmpty && selectedGenre == 'All') {
    return service.getPopularManga(limit: 40);
  }

  List<String>? includedTags;
  if (selectedGenre != 'All') {
    try {
      final tags = await service.getTags();
      Map<String, dynamic>? matchedTag;
      for (final tag in tags) {
        final name = (tag['name'] as String?) ?? '';
        if (name.toLowerCase() == selectedGenre.toLowerCase()) {
          matchedTag = tag;
          break;
        }
      }
      if (matchedTag != null) {
        includedTags = [matchedTag['id'] as String];
      }
    } catch (_) {}
  }

  return service.searchManga(
    query,
    limit: 40,
    includedTags: includedTags,
  );
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> genres = [
    {'name': 'All', 'color': const Color(0xFFA855F7)},
    {'name': 'Action', 'color': const Color(0xFFEF4444)},
    {'name': 'Romance', 'color': const Color(0xFFEC4899)},
    {'name': 'Horror', 'color': const Color(0xFF8B5CF6)},
    {'name': 'Comedy', 'color': const Color(0xFFFCD34D)},
    {'name': 'Drama', 'color': const Color(0xFF06B6D4)},
    {'name': 'Fantasy', 'color': const Color(0xFF8B5CF6)},
    {'name': 'Sci-Fi', 'color': const Color(0xFF3B82F6)},
  ];

  String selectedGenre = 'All';
  bool showAll = false;

  Widget _buildCoverImage(String coverUrl, {double? width, double? height}) {
    if (coverUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2A2A), Color(0xFF1F1F1F)],
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[850],
            ),
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: width != null ? width * 0.3 : 40,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final bool isSearching =
        _searchController.text.isNotEmpty || selectedGenre != 'All';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: CustomScrollView(
        slivers: [
          // Search bar
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF1A1A1A),
            floating: true,
            elevation: 0,
            title: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A2A2A), Color(0xFF1F1F1F)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search manga, comics...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.tune, color: Colors.grey[400]),
                onPressed: () {
                  // TODO: Add filter functionality
                },
              ),
            ],
          ),

          // Genre filter chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  final genre = genres[index];
                  final isSelected = genre['name'] == selectedGenre;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        final name = genre['name'] as String;
                        setState(() {
                          selectedGenre = name;
                          showAll = false;
                        });
                        ref.read(selectedGenreProvider.notifier).state = name;
                        // TODO: Implement genre filtering
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    genre['color'] as Color,
                                    (genre['color'] as Color).withOpacity(0.7),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : const Color(0xFF2A2A2A),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          genre['name'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Trending section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSearching ? 'Search Results' : 'Trending',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (selectedGenre != 'All')
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showAll = !showAll;
                        });
                      },
                      child: Text(
                        showAll ? 'Show less' : 'See all',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFA855F7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Trending/Search Results List
          searchResults.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFFA855F7)),
                      SizedBox(height: 16),
                      Text(
                        'Loading...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[400],
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading manga',
                        style: TextStyle(color: Colors.red[400]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (mangas) {
              if (mangas.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            color: Colors.grey[600],
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No manga found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try searching with different keywords',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (showAll && selectedGenre != 'All') {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final manga = mangas[index];
                      final coverUrl = manga.getCoverUrl();

                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: GestureDetector(
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
                                        manga.description ??
                                        'No description available.',
                                    'description':
                                        manga.description ??
                                        'No description available.',
                                    'status': manga.status,
                                    'tags': manga.tags,
                                    'genres': manga.tags.take(5).toList(),
                                    'rating':
                                        0.0, // MangaDex API doesn't provide ratings in listing
                                    'chapters':
                                        0, // Would need separate API call
                                    'source': 'MangaDex',
                                    'ageRating': _getAgeRating(manga.tags),
                                    'createdAt':
                                        manga.createdAt?.toString() ?? '',
                                    'updatedAt':
                                        manga.updatedAt?.toString() ?? '',
                                  },
                                ),
                              ),
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCoverImage(
                                coverUrl,
                                width: 80,
                                height: 120,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
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
                                    Text(
                                      manga.authors.isNotEmpty
                                          ? manga.authors.first
                                          : 'Unknown Author',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: mangas.length,
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: mangas.length,
                    itemBuilder: (context, index) {
                      final manga = mangas[index];
                      final coverUrl = manga.getCoverUrl();

                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            // Properly extract all data from MangaDexManga model
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
                                        manga.description ??
                                        'No description available.',
                                    'description':
                                        manga.description ??
                                        'No description available.',
                                    'status': manga.status,
                                    'tags': manga.tags,
                                    'genres': manga.tags.take(5).toList(),
                                    'rating':
                                        0.0, // MangaDex API doesn't provide ratings in listing
                                    'chapters':
                                        0, // Would need separate API call
                                    'source': 'MangaDex',
                                    'ageRating': _getAgeRating(manga.tags),
                                    'createdAt':
                                        manga.createdAt?.toString() ?? '',
                                    'updatedAt':
                                        manga.updatedAt?.toString() ?? '',
                                  },
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cover image
                              _buildCoverImage(
                                coverUrl,
                                width: 160,
                                height: 200,
                              ),
                              const SizedBox(height: 12),
                              // Title
                              SizedBox(
                                width: 160,
                                child: Text(
                                  manga.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Author
                              SizedBox(
                                width: 160,
                                child: Text(
                                  manga.authors.isNotEmpty
                                      ? manga.authors.first
                                      : 'Unknown Author',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ),
        ],
      ),
    );
  }

  // Helper method to determine age rating based on tags
  String _getAgeRating(List<String> tags) {
    // Common mature content tags
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
