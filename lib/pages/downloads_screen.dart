import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komikap/state/firebase_providers.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: _buildDownloadsList(context, ref),
    );
  }

  Widget _buildDownloadsList(BuildContext context, WidgetRef ref) {
    // Get all downloaded chapters
    // Since we don't have a provider for all downloads, we'll show a message
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
            'Downloaded Chapters',
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
