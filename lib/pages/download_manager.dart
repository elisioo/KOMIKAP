import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komikap/services/local_cache_service.dart';
import 'package:komikap/models/firebase_models.dart';

class DownloadManager {
  static final LocalCacheService _cacheService = LocalCacheService();

  /// Download a chapter
  static Future<void> downloadChapter({
    required String mangaId,
    required String chapterId,
    required String chapterTitle,
    required int chapterNumber,
    required List<String> pageImageUrls,
    required Function(int) onProgress,
    required Function(String) onError,
  }) async {
    try {
      print('Starting download: $chapterTitle');
      
      // Simulate downloading pages
      final pageImagePaths = <String>[];
      int downloaded = 0;

      for (String url in pageImageUrls) {
        try {
          // In a real app, you would download the image here
          // For now, we'll just store the URL as the path
          pageImagePaths.add(url);
          downloaded++;
          onProgress((downloaded / pageImageUrls.length * 100).toInt());
          
          // Simulate download delay
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          print('Failed to download page: $e');
          onError('Failed to download page: $e');
        }
      }

      print('Pages downloaded: ${pageImagePaths.length}');
      print('Saving to database...');

      // Save to database
      final chapter = DownloadedChapter(
        id: '${mangaId}_${chapterId}',
        mangaId: mangaId,
        chapterId: chapterId,
        chapterTitle: chapterTitle,
        chapterNumber: chapterNumber,
        pageImagePaths: pageImagePaths,
        downloadedAt: DateTime.now(),
        sizeInBytes: pageImagePaths.length * 1024 * 500, // Estimate 500KB per page
      );

      await _cacheService.saveDownloadedChapter(chapter);
      print('Chapter saved successfully!');
      onProgress(100);
    } catch (e) {
      print('Download failed: $e');
      onError('Download failed: $e');
    }
  }

  /// Check if chapter is downloaded
  static Future<bool> isChapterDownloaded(String chapterId) async {
    final chapter = await _cacheService.getDownloadedChapter(chapterId);
    return chapter != null;
  }

  /// Delete downloaded chapter
  static Future<void> deleteDownloadedChapter(String chapterId) async {
    await _cacheService.deleteDownloadedChapter(chapterId);
  }

  /// Get all downloaded chapters for a manga
  static Future<List<DownloadedChapter>> getDownloadedChapters(String mangaId) async {
    return _cacheService.getDownloadedChaptersByManga(mangaId);
  }

  /// Get total download size
  static Future<int> getTotalDownloadSize() async {
    return _cacheService.getTotalDownloadSize();
  }

  /// Format bytes to readable format
  static String formatBytes(int bytes) {
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

/// Download progress dialog
class DownloadProgressDialog extends StatefulWidget {
  final String chapterTitle;
  final String mangaId;
  final String chapterId;
  final int chapterNumber;
  final List<String> pageUrls;

  const DownloadProgressDialog({
    required this.chapterTitle,
    required this.mangaId,
    required this.chapterId,
    required this.chapterNumber,
    required this.pageUrls,
  });

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  int _progress = 0;
  String _status = 'Starting download...';
  bool _isComplete = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  void _startDownload() async {
    try {
      await DownloadManager.downloadChapter(
        mangaId: widget.mangaId,
        chapterId: widget.chapterId,
        chapterTitle: widget.chapterTitle,
        chapterNumber: widget.chapterNumber,
        pageImageUrls: widget.pageUrls,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _status = 'Downloaded $progress%';
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _error = error;
              _status = 'Error: $error';
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isComplete = true;
          _status = 'Download complete!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _status = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(
        widget.chapterTitle,
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[700],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFA855F7),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _status,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      actions: [
        if (_isComplete || _error != null)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done', style: TextStyle(color: Color(0xFFA855F7))),
          ),
      ],
    );
  }
}
