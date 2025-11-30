import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komikap/pages/comicpageview.dart';
import 'package:komikap/state/manga_providers.dart';
import 'package:komikap/models/mangadexmanga.dart';

// State providers for reader settings
final readerModeProvider = StateProvider<ReadingMode>(
  (ref) => ReadingMode.vertical,
);

class ReaderScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> comic;
  final String? chapterId;
  final int chapter;
  final String mangaId;

  const ReaderScreen({
    Key? key,
    required this.comic,
    this.chapterId,
    this.chapter = 1,
    required this.mangaId,
  }) : super(key: key);

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  int currentPage = 0;
  bool showControls = true;
  late String currentChapterId;
  int currentChapterIndex = 0;
  List<MangaDexChapter> allChapters = [];

  @override
  void initState() {
    super.initState();
    currentChapterId = widget.chapterId ?? '';
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final chapters = await ref.read(
      mangaChaptersProvider(widget.mangaId).future,
    );
    setState(() {
      allChapters = chapters;
      if (currentChapterId.isNotEmpty) {
        currentChapterIndex = chapters.indexWhere(
          (ch) => ch.id == currentChapterId,
        );
        if (currentChapterIndex == -1) currentChapterIndex = 0;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToChapter(String chapterId, int index) {
    setState(() {
      currentChapterId = chapterId;
      currentChapterIndex = index;
      currentPage = 0;
    });
    Navigator.pop(context); // Close the chapter list
  }

  @override
  Widget build(BuildContext context) {
    final readingMode = ref.watch(readerModeProvider);
    final comicTitle = widget.comic['title'] ?? 'Unknown Comic';

    // If no chapter ID, show error
    if (currentChapterId.isEmpty) {
      return _buildErrorState('No chapter selected');
    }

    // Load real chapter pages from API
    final pageUrlsAsync = ref.watch(chapterPageUrlsProvider(currentChapterId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: pageUrlsAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error),
        data: (pageUrls) => _buildReaderContent(
          comicTitle,
          readingMode,
          pageUrls,
          currentChapterId,
        ),
      ),
    );
  }

  Widget _buildReaderContent(
    String comicTitle,
    ReadingMode readingMode,
    List<String> pageUrls,
    String chapterId,
  ) {
    return Stack(
      children: [
        // Comic pages
        GestureDetector(
          onTap: () {
            setState(() => showControls = !showControls);
          },
          child: pageUrls.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No pages available',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                )
              : ComicPageView(
                  pageUrls: pageUrls,
                  initialPage: currentPage,
                  readingMode: readingMode,
                  onPageChanged: (page) {
                    setState(() => currentPage = page);
                  },
                ),
        ),
        _buildTopControls(comicTitle, pageUrls.length),
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFA855F7)),
          const SizedBox(height: 16),
          const Text(
            'Loading chapter...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls(String comicTitle, int totalPages) {
    final currentChapter =
        allChapters.isNotEmpty &&
            currentChapterIndex >= 0 &&
            currentChapterIndex < allChapters.length
        ? allChapters[currentChapterIndex]
        : null;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !showControls,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.comic['title'] ?? 'Unknown Comic',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            currentChapter != null
                                ? '${currentChapter.displayName} - Page ${currentPage + 1}/$totalPages'
                                : 'Page ${currentPage + 1}/$totalPages',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {
                        _showReaderOptions(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final hasNextChapter = currentChapterIndex < allChapters.length - 1;
    final hasPrevChapter = currentChapterIndex > 0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !showControls,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.skip_previous,
                        color: hasPrevChapter ? Colors.white : Colors.grey,
                      ),
                      onPressed: hasPrevChapter
                          ? () {
                              final prevChapter =
                                  allChapters[currentChapterIndex - 1];
                              _navigateToChapter(
                                prevChapter.id,
                                currentChapterIndex - 1,
                              );
                            }
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.bookmark_border,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to bookmarks'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        _showReaderSettings(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.format_list_bulleted,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _showChapterList(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        color: hasNextChapter ? Colors.white : Colors.grey,
                      ),
                      onPressed: hasNextChapter
                          ? () {
                              final nextChapter =
                                  allChapters[currentChapterIndex + 1];
                              _navigateToChapter(
                                nextChapter.id,
                                currentChapterIndex + 1,
                              );
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showReaderOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Reader Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark, color: Color(0xFFA855F7)),
              title: const Text(
                'Add Bookmark',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bookmark added'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFFA855F7)),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReaderSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Reader Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Reading Mode Control
            Consumer(
              builder: (context, ref, child) {
                final readingMode = ref.watch(readerModeProvider);
                return ListTile(
                  leading: const Icon(
                    Icons.view_agenda,
                    color: Color(0xFFA855F7),
                  ),
                  title: const Text(
                    'Reading Mode',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: DropdownButton<ReadingMode>(
                    value: readingMode,
                    dropdownColor: const Color(0xFF2A2A2A),
                    items: [
                      DropdownMenuItem(
                        value: ReadingMode.vertical,
                        child: Text(
                          'Vertical',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ReadingMode.horizontal,
                        child: Text(
                          'Horizontal',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(readerModeProvider.notifier).state = value;
                        Navigator.pop(context); // Close settings to see change
                      }
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showChapterList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Chapters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: allChapters.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFA855F7),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: allChapters.length,
                          itemBuilder: (context, index) {
                            final chapter = allChapters[index];
                            final isCurrentChapter =
                                index == currentChapterIndex;

                            return ListTile(
                              tileColor: isCurrentChapter
                                  ? const Color(0xFFA855F7).withOpacity(0.2)
                                  : null,
                              leading: isCurrentChapter
                                  ? const Icon(
                                      Icons.play_arrow,
                                      color: Color(0xFFA855F7),
                                    )
                                  : null,
                              title: Text(
                                chapter.displayName,
                                style: TextStyle(
                                  color: isCurrentChapter
                                      ? const Color(0xFFA855F7)
                                      : Colors.white,
                                  fontWeight: isCurrentChapter
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                '${chapter.pages} pages${chapter.scanlationGroup != null ? ' • ${chapter.scanlationGroup}' : ''}',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                              onTap: () {
                                _navigateToChapter(chapter.id, index);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
