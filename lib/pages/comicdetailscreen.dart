import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komikap/pages/readerscreen.dart';
import 'package:komikap/pages/download_manager.dart';
import 'package:komikap/state/manga_providers.dart';
import 'package:komikap/state/firebase_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComicDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> comic;

  const ComicDetailScreen({super.key, required this.comic});

  @override
  ConsumerState<ComicDetailScreen> createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends ConsumerState<ComicDetailScreen> {
  bool isDescriptionExpanded = false;
  int _displayedChapterCount = 10; // Initially show 10 chapters

  @override
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey[400], size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.comic['title'] ?? 'Unknown Comic';
    final author = widget.comic['author'] ?? 'Unknown Author';
    final artist =
        widget.comic['artist'] ?? widget.comic['author'] ?? 'Unknown Artist';
    final coverUrl = widget.comic['coverUrl'] ?? '';
    final rating = widget.comic['rating'] ?? 0.0;
    final chapters = widget.comic['chapters'] ?? 0;
    final genres =
        widget.comic['genres'] ?? ['Action', 'Comedy', 'Drama', 'Shonen'];
    final status = widget.comic['status'] ?? 'Ongoing';
    final ageRating = widget.comic['ageRating'] ?? '+14';
    final mangaId = widget.comic['id'] ?? widget.comic['mangaId'];

    print('🎨 Comic Details:');
    print('   Title: $title');
    print('   Author: $author');
    print('   Artist: $artist');
    print('   Cover URL: $coverUrl');
    print('   Manga ID: $mangaId');
    print(
      '   Synopsis: ${widget.comic['synopsis'] ?? widget.comic['description']}',
    );

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Cover Section
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Background cover with gradient overlay
                    Container(
                      height: 430,
                      decoration: BoxDecoration(
                        image: coverUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(coverUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey[850],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF121212).withOpacity(0.7),
                              const Color(0xFF121212),
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Content overlay
                    Positioned(
                      left: 16,
                      bottom: 16,
                      right: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Comic cover thumbnail
                          Container(
                            width: 120,
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: coverUrl.isNotEmpty
                                  ? Image.network(
                                      coverUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[800],
                                              child: const Icon(
                                                Icons.book,
                                                size: 40,
                                                color: Colors.white54,
                                              ),
                                            );
                                          },
                                    )
                                  : Container(
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.book,
                                        size: 40,
                                        color: Colors.white54,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Title and metadata
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // Author (not uppercased)
                                Text(
                                  author,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Artist if different from author
                                if (artist != author &&
                                    artist != 'Unknown Artist') ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Art: $artist',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 12),
                                // Genres
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: genres.take(4).map<Widget>((genre) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Text(
                                        genre,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[300],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 12),
                                // Age rating and status
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red[700],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        ageRating,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: status.toLowerCase() == 'ongoing'
                                            ? Colors.green[700]
                                            : Colors.blue[700],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
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
                  ],
                ),
              ),

              // Description Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isDescriptionExpanded = !isDescriptionExpanded;
                              });
                            },
                            child: Text(
                              isDescriptionExpanded ? 'Less' : 'More',
                              style: const TextStyle(
                                color: Color(0xFFA855F7),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.comic['synopsis'] ??
                            widget.comic['description'] ??
                            'No description available.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.grey[300],
                        ),
                        maxLines: isDescriptionExpanded ? null : 3,
                        overflow: isDescriptionExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Source:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.comic['source'] ?? 'MangaDex',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Filter and sort icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chapters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  // TODO: Add sort functionality
                                },
                                icon: const Icon(Icons.sort),
                                color: Colors.grey[400],
                                iconSize: 24,
                              ),
                              IconButton(
                                onPressed: () {
                                  // TODO: Add filter functionality
                                },
                                icon: const Icon(Icons.filter_list),
                                color: Colors.grey[400],
                                iconSize: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Chapter List
              SliverToBoxAdapter(child: _buildChapterList()),

              // Bottom padding for floating button
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
            ),
          ),

          // Bottom action bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: Colors.black.withOpacity(0.25),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          // Save Button
                          _buildActionButton(
                            icon: Icons.bookmark_border,
                            label: 'Save',
                            onTap: () async {
                              if (mangaId == null || (mangaId is String && mangaId.isEmpty)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Unable to save this manga'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please login to save manga'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              try {
                                await ref
                                    .read(savedMangaNotifierProvider(user.uid).notifier)
                                    .saveManga(
                                      mangaId: mangaId,
                                      title: title,
                                      coverImageUrl: coverUrl,
                                    );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to bookmarks'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } catch (_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to save manga'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 12),

                          // Read Button (Main Action - Highlighted)
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFA855F7),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFA855F7,
                                    ).withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: mangaId != null
                                    ? () async {
                                        // Get first chapter
                                        final chapters = await ref.read(
                                          mangaChaptersProvider(mangaId).future,
                                        );

                                        if (chapters.isNotEmpty) {
                                          final firstChapter = chapters.first;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ReaderScreen(
                                                    comic: widget.comic,
                                                    chapterId: firstChapter.id,
                                                    chapter:
                                                        int.tryParse(
                                                          firstChapter
                                                                  .chapter ??
                                                              '1',
                                                        ) ??
                                                        1,
                                                    mangaId: mangaId,
                                                  ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'No chapters available',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Read Now',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Favorites Button
                          _buildActionButton(
                            icon: Icons.favorite_border,
                            label: 'Fav',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to favorites'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterList() {
    final mangaId = widget.comic['id'] ?? widget.comic['mangaId'];

    if (mangaId == null) {
      return _buildMockChapterList();
    }

    final chaptersAsync = ref.watch(mangaChaptersProvider(mangaId));

    return chaptersAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(color: Color(0xFFA855F7)),
              const SizedBox(height: 16),
              const Text(
                'Loading chapters...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red[400], size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading chapters',
                style: TextStyle(color: Colors.red[400], fontSize: 16),
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
      data: (chapters) {
        if (chapters.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    color: Colors.grey[600],
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No chapters available',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for updates',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        final displayedChapters = chapters
            .take(_displayedChapterCount)
            .toList();
        final hasMoreChapters = chapters.length > _displayedChapterCount;

        return Column(
          children: [
            // Download All button header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chapters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showDownloadAllConfirmation(context, chapters, mangaId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA855F7),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text(
                      'Download All',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedChapters.length,
              itemBuilder: (context, index) {
                final chapter = displayedChapters[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      chapter.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        chapter.publishAt.toString().split(' ')[0],
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${chapter.pages} pages',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.download_outlined),
                          color: Colors.grey[400],
                          iconSize: 20,
                          onPressed: () => _downloadSingleChapter(
                            context,
                            mangaId,
                            chapter.id,
                            chapter.displayName,
                            int.tryParse(chapter.chapter ?? '1') ?? 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReaderScreen(
                            comic: widget.comic,
                            chapterId: chapter.id,
                            chapter: int.tryParse(chapter.chapter ?? '0') ?? 0,
                            mangaId: mangaId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            // View More button - only show if there are more chapters
            if (hasMoreChapters)
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _displayedChapterCount += 20; // Load 20 more chapters
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFA855F7),
                    side: const BorderSide(color: Color(0xFFA855F7)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Load More (${chapters.length - _displayedChapterCount} remaining)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.expand_more, size: 20),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _downloadSingleChapter(
    BuildContext context,
    String mangaId,
    String chapterId,
    String chapterTitle,
    int chapterNumber,
  ) {
    // Mock page URLs
    final mockPageUrls = List.generate(
      20,
      (index) => 'https://example.com/page_${index + 1}.jpg',
    );

    // Get manga details from widget
    final mangaTitle = widget.comic['title'] ?? 'Unknown Manga';
    final mangaCoverUrl = widget.comic['coverUrl'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DownloadProgressDialog(
        chapterTitle: chapterTitle,
        mangaId: mangaId,
        chapterId: chapterId,
        chapterNumber: chapterNumber,
        pageUrls: mockPageUrls,
        mangaTitle: mangaTitle,
        mangaCoverUrl: mangaCoverUrl,
      ),
    );
  }

  void _showDownloadAllConfirmation(
    BuildContext context,
    List<dynamic> chapters,
    String mangaId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Download All Chapters?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Download all ${chapters.length} chapters?\n\nThis may take a while and use significant storage.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadAllChapters(context, chapters, mangaId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA855F7),
            ),
            child: const Text('Download All'),
          ),
        ],
      ),
    );
  }

  void _downloadAllChapters(
    BuildContext context,
    List<dynamic> chapters,
    String mangaId,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting download of ${chapters.length} chapters...'),
        duration: const Duration(seconds: 3),
      ),
    );

    // Download chapters sequentially
    for (int i = 0; i < chapters.length; i++) {
      final chapter = chapters[i];
      Future.delayed(Duration(milliseconds: i * 500), () {
        _downloadSingleChapter(
          context,
          mangaId,
          chapter.id,
          chapter.displayName,
          int.tryParse(chapter.chapter ?? '1') ?? 1,
        );
      });
    }
  }

  Widget _buildMockChapterList() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.library_books_outlined,
              color: Colors.grey[600],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No chapters available',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for updates',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
