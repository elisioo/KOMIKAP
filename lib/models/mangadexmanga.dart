class MangaDexManga {
  final String id;
  final String title;
  final String? description;
  final String status;
  final List<String> tags;
  final List<String> authors;
  final List<String> artists;
  final String? coverArtId;
  final String? coverFileName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MangaDexManga({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.tags,
    required this.authors,
    required this.artists,
    this.coverArtId,
    this.coverFileName,
    this.createdAt,
    this.updatedAt,
  });

  factory MangaDexManga.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>;
    final relationships = json['relationships'] as List<dynamic>? ?? [];

    // Extract title
    final titleMap = attributes['title'] as Map<String, dynamic>? ?? {};
    final title =
        titleMap['en'] ?? titleMap.values.firstOrNull ?? 'Unknown Title';

    // Extract description
    final descMap = attributes['description'] as Map<String, dynamic>? ?? {};
    final description = descMap['en'] ?? descMap.values.firstOrNull;

    // Extract status
    final status = attributes['status'] as String? ?? 'unknown';

    // Extract tags
    final tagList = attributes['tags'] as List<dynamic>? ?? [];
    final tags = tagList.map((tag) {
      final tagAttributes = tag['attributes'] as Map<String, dynamic>? ?? {};
      final tagName = tagAttributes['name'] as Map<String, dynamic>? ?? {};
      return tagName['en'] as String? ?? 'Unknown';
    }).toList();

    // Extract authors and artists from relationships
    final authors = <String>[];
    final artists = <String>[];
    String? coverArtId;
    String? coverFileName;

    for (var rel in relationships) {
      final type = rel['type'] as String?;
      final relAttributes = rel['attributes'] as Map<String, dynamic>?;

      if (type == 'author' && relAttributes != null) {
        authors.add(relAttributes['name'] as String? ?? 'Unknown');
      } else if (type == 'artist' && relAttributes != null) {
        artists.add(relAttributes['name'] as String? ?? 'Unknown');
      } else if (type == 'cover_art') {
        coverArtId = rel['id'] as String?;
        if (relAttributes != null) {
          coverFileName = relAttributes['fileName'] as String?;
        }
      }
    }

    return MangaDexManga(
      id: json['id'] as String,
      title: title,
      description: description,
      status: status,
      tags: tags,
      authors: authors,
      artists: artists,
      coverArtId: coverArtId,
      coverFileName: coverFileName,
      createdAt: attributes['createdAt'] != null
          ? DateTime.tryParse(attributes['createdAt'])
          : null,
      updatedAt: attributes['updatedAt'] != null
          ? DateTime.tryParse(attributes['updatedAt'])
          : null,
    );
  }

  /// Get the full cover URL for this manga
  /// MangaDex cover URL format: https://uploads.mangadex.org/covers/{manga-id}/{cover-filename}
  String getCoverUrl({String quality = 'original'}) {
    if (coverFileName == null || coverFileName!.isEmpty) {
      return '';
    }

    // For different quality options:
    // - original: full quality
    // - 512: 512px width
    // - 256: 256px width
    String fileName = coverFileName!;
    if (quality != 'original') {
      // Add quality suffix before extension
      final parts = fileName.split('.');
      if (parts.length > 1) {
        final extension = parts.last;
        final nameWithoutExt = parts.sublist(0, parts.length - 1).join('.');
        fileName = '$nameWithoutExt.$quality.jpg';
      }
    }

    return 'https://uploads.mangadex.org/covers/$id/$fileName';
  }

  /// Get a thumbnail version of the cover (256px)
  String getThumbnailUrl() {
    return getCoverUrl(quality: '256');
  }

  /// Get a medium version of the cover (512px)
  String getMediumUrl() {
    return getCoverUrl(quality: '512');
  }
}

class MangaDexChapter {
  final String id;
  final String? volume;
  final String? chapter;
  final String? title;
  final String translatedLanguage;
  final int pages;
  final DateTime publishAt;
  final String? scanlationGroup;

  MangaDexChapter({
    required this.id,
    this.volume,
    this.chapter,
    this.title,
    required this.translatedLanguage,
    required this.pages,
    required this.publishAt,
    this.scanlationGroup,
  });

  factory MangaDexChapter.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>;
    final relationships = json['relationships'] as List<dynamic>? ?? [];

    // Extract scanlation group
    String? scanlationGroup;
    for (var rel in relationships) {
      if (rel['type'] == 'scanlation_group') {
        final relAttributes = rel['attributes'] as Map<String, dynamic>?;
        scanlationGroup = relAttributes?['name'] as String?;
        break;
      }
    }

    return MangaDexChapter(
      id: json['id'] as String,
      volume: attributes['volume'] as String?,
      chapter: attributes['chapter'] as String?,
      title: attributes['title'] as String?,
      translatedLanguage: attributes['translatedLanguage'] as String? ?? 'en',
      pages: attributes['pages'] as int? ?? 0,
      publishAt: DateTime.parse(attributes['publishAt'] as String),
      scanlationGroup: scanlationGroup,
    );
  }

  String get displayName {
    final parts = <String>[];

    if (volume != null && volume!.isNotEmpty) {
      parts.add('Vol. $volume');
    }

    if (chapter != null && chapter!.isNotEmpty) {
      parts.add('Ch. $chapter');
    } else {
      parts.add('Chapter');
    }

    if (title != null && title!.isNotEmpty) {
      parts.add('- $title');
    }

    return parts.join(' ');
  }
}

class MangaDexPageData {
  final String baseUrl;
  final String hash;
  final List<String> data;
  final List<String> dataSaver;

  MangaDexPageData({
    required this.baseUrl,
    required this.hash,
    required this.data,
    required this.dataSaver,
  });

  factory MangaDexPageData.fromJson(Map<String, dynamic> json) {
    final chapter = json['chapter'] as Map<String, dynamic>;

    return MangaDexPageData(
      baseUrl: json['baseUrl'] as String,
      hash: chapter['hash'] as String,
      data: (chapter['data'] as List<dynamic>).cast<String>(),
      dataSaver: (chapter['dataSaver'] as List<dynamic>).cast<String>(),
    );
  }

  /// Get page URLs (original quality)
  List<String> getPageUrls() {
    return data.map((filename) => '$baseUrl/data/$hash/$filename').toList();
  }

  /// Get page URLs (data saver quality - smaller file size)
  List<String> getDataSaverPageUrls() {
    return dataSaver
        .map((filename) => '$baseUrl/data-saver/$hash/$filename')
        .toList();
  }
}
