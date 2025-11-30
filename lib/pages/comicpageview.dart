import 'package:flutter/material.dart';

enum ReadingMode { vertical, horizontal }

class ComicPageView extends StatefulWidget {
  final List<String> pageUrls;
  final int initialPage;
  final ReadingMode readingMode;
  final Function(int) onPageChanged;

  const ComicPageView({
    Key? key,
    required this.pageUrls,
    required this.initialPage,
    required this.readingMode,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  State<ComicPageView> createState() => _ComicPageViewState();
}

class _ComicPageViewState extends State<ComicPageView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Validate that pageUrls is not empty
    if (widget.pageUrls.isEmpty) {
      return const Center(
        child: Text(
          'No pages available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    if (widget.readingMode == ReadingMode.vertical) {
      return ListView.builder(
        itemCount: widget.pageUrls.length,
        itemBuilder: (context, index) {
          return _buildPageImage(widget.pageUrls[index], index);
        },
      );
    } else {
      return PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          widget.onPageChanged(page);
        },
        itemCount: widget.pageUrls.length,
        itemBuilder: (context, index) {
          return _buildPageImage(widget.pageUrls[index], index);
        },
      );
    }
  }

  Widget _buildPageImage(String pageUrl, int index) {
    // Validate that pageUrl is not null or empty
    if (pageUrl.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Image.network(
        pageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFA855F7),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load page ${index + 1}',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
