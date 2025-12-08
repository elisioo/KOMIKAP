import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komikap/pages/comicdetailscreen.dart';
import 'package:komikap/pages/viewallmangascreen.dart';
import 'package:komikap/state/manga_providers.dart';
import 'package:komikap/pages/readerscreen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

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
            size: width != null ? width * 0.4 : 40,
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
              size: width != null ? width * 0.4 : 40,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingMangaProvider);
    final recentAsync = ref.watch(recentlyUpdatedMangaProvider);
    final continueReadingAsync = ref.watch(continueReadingProvider);

    return SafeArea(
      left: true,
      right: true,
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: const Color(0xFF1A1A1A),
              floating: true,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFA855F7),
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning, Eli',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      Text(
                        'Top comics are waiting for you',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white70,
                  ),
                  onPressed: () {},
                ),
              ],
            ),

            // Continue Reading Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Continue Reading',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    continueReadingAsync.when(
                      loading: () => Text(
                        'Loading your last read...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      error: (error, stack) => Text(
                        'Unable to load last read',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      data: (comic) {
                        if (comic == null) {
                          return Text(
                            'Start reading a manga to see it here.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          );
                        }

                        return GestureDetector(
                          onTap: () async {
                            final mangaId = comic['mangaId'] as String?;
                            final title = comic['title'] as String? ?? 'Unknown';
                            final coverUrl = comic['coverUrl'] as String? ?? '';
                            final chapterNumber =
                                comic['chapterNumber'] as int? ?? 0;

                            if (mangaId == null || mangaId.isEmpty) {
                              return;
                            }

                            try {
                              final chapters = await ref.read(
                                mangaChaptersProvider(mangaId).future,
                              );

                              if (chapters.isEmpty) {
                                return;
                              }

                              var target = chapters.first;
                              if (chapterNumber > 0) {
                                final match = chapters.firstWhere(
                                  (ch) =>
                                      int.tryParse(ch.chapter ?? '') ==
                                      chapterNumber,
                                  orElse: () => chapters.first,
                                );
                                target = match;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReaderScreen(
                                    comic: {
                                      'id': mangaId,
                                      'mangaId': mangaId,
                                      'title': title,
                                      'author': '',
                                      'coverUrl': coverUrl,
                                    },
                                    chapterId: target.id,
                                    chapter:
                                        int.tryParse(target.chapter ?? '1') ?? 1,
                                    mangaId: mangaId,
                                  ),
                                ),
                              );
                            } catch (_) {}
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2A2A2A),
                                  Color(0xFF1F1F1F),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _buildCoverImage(
                                      comic['coverUrl'] ?? '',
                                      width: 80,
                                      height: 100,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comic['title'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comic['chapter'] ?? 'Chapter 1',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFA855F7),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Trending Now Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trending Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewAllMangaScreen(
                              category: 'trending',
                              title: 'Trending Manga',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFA855F7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Trending Manga Horizontal List
            SliverToBoxAdapter(
              child: trendingAsync.when(
                loading: () => SizedBox(
                  height: 240,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFFA855F7),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Loading trending manga...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (error, stack) => SizedBox(
                  height: 240,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[400],
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading manga',
                          style: TextStyle(color: Colors.red[400]),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            error.toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (mangas) {
                  if (mangas.isEmpty) {
                    return SizedBox(
                      height: 240,
                      child: Center(
                        child: Text(
                          'No manga found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 240,
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ComicDetailScreen(
                                    comic: {
                                      'id': manga.id,
                                      'mangaId': manga.id,
                                      'title': manga.title,
                                      'author': manga.authors.isNotEmpty
                                          ? manga.authors.first
                                          : 'Unknown',
                                      'coverUrl': coverUrl,
                                      'synopsis':
                                          manga.description ??
                                          'No description available',
                                      'description': manga.description ?? '',
                                      'status': manga.status,
                                      'tags': manga.tags,
                                      'genres': manga.tags.take(4).toList(),
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _buildCoverImage(
                                    coverUrl,
                                    width: 150,
                                    height: 240,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          manga.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          manga.status,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Recently Updated Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recently Updated',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewAllMangaScreen(
                              category: 'recent',
                              title: 'Recently Updated',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFA855F7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recently Updated List
            SliverToBoxAdapter(
              child: recentAsync.when(
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFFA855F7),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Loading recently updated...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Error loading manga',
                    style: TextStyle(color: Colors.red[400]),
                  ),
                ),
                data: (mangas) {
                  if (mangas.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'No recently updated manga',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: mangas.map((manga) {
                        final coverUrl = manga.getCoverUrl();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
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
                                          ? manga.authors.first
                                          : 'Unknown',
                                      'coverUrl': coverUrl,
                                      'synopsis':
                                          manga.description ??
                                          'No description available',
                                      'description': manga.description ?? '',
                                      'status': manga.status,
                                      'tags': manga.tags,
                                      'genres': manga.tags.take(4).toList(),
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildCoverImage(
                                    coverUrl,
                                    width: 60,
                                    height: 80,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        manga.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        manga.status,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
