import 'package:flutter/material.dart';

class MangaCoverImage extends StatelessWidget {
  final String coverUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const MangaCoverImage({
    Key? key,
    required this.coverUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (coverUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: Image.network(
        coverUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            width: width,
            height: height,
            color: Colors.grey[850],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFFA855F7),
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading cover image: $error');
          print('URL attempted: $coverUrl');
          return _buildPlaceholder();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF2A2A2A), const Color(0xFF1F1F1F)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.book_outlined,
          size: width != null ? width! * 0.4 : 40,
          color: Colors.white54,
        ),
      ),
    );
  }
}

/// Thumbnail version for lists
class MangaThumbnail extends StatelessWidget {
  final String coverUrl;
  final double size;
  final VoidCallback? onTap;

  const MangaThumbnail({
    Key? key,
    required this.coverUrl,
    this.size = 80,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MangaCoverImage(
        coverUrl: coverUrl,
        width: size,
        height: size * 1.4,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
