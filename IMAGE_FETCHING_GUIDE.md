# Image Fetching Guide - KOMIKAP

## 📸 Available Image Methods

Your manga model now has multiple image fetching methods for different use cases:

### 1. **Cover Image (Medium Quality)**
```dart
final manga = await service.getMangaById(mangaId);
final coverUrl = manga.getCoverUrl(); // Default medium quality
// URL: https://uploads.mangadex.org/covers/{mangaId}/{coverArtId}.medium.jpg
```

### 2. **High-Quality Cover (Detail Screen)**
```dart
final manga = await service.getMangaById(mangaId);
final coverUrlHQ = manga.getCoverUrlHQ(); // 512px
// URL: https://uploads.mangadex.org/covers/{mangaId}/{coverArtId}.512.jpg
```

### 3. **Background Image**
```dart
final manga = await service.getMangaById(mangaId);
final backgroundUrl = manga.getBackgroundUrl(); // Same as cover
// URL: https://uploads.mangadex.org/covers/{mangaId}/{backgroundImageId}.medium.jpg
```

### 4. **Thumbnail Image (Small)**
```dart
final manga = await service.getMangaById(mangaId);
final thumbnailUrl = manga.getThumbnailUrl(); // 256px
// URL: https://uploads.mangadex.org/covers/{mangaId}/{coverArtId}.256.jpg
```

### 5. **Custom Quality**
```dart
final manga = await service.getMangaById(mangaId);
final customUrl = manga.getCoverUrl(quality: 'original'); // Full resolution
// Supported qualities: 256, 512, original, medium
```

---

## 🎨 Image Quality Options

| Quality | Size | Use Case |
|---------|------|----------|
| `256` | 256px | Thumbnails, lists |
| `512` | 512px | Detail screens, cards |
| `medium` | ~300px | Default, general use |
| `original` | Full | High-res display |

---

## 📊 Additional Metadata

The manga model now includes:

```dart
final manga = await service.getMangaById(mangaId);

// Rating (0-10)
print(manga.rating); // e.g., 8

// View count / Follows
print(manga.views); // e.g., 15000

// Status
print(manga.status); // e.g., "ongoing"

// Year published
print(manga.year); // e.g., 2020

// Content rating
print(manga.contentRating); // e.g., "suggestive"

// Authors
print(manga.authors); // List of author names

// Artists
print(manga.artists); // List of artist names

// Tags/Genres
print(manga.tags); // List of genre tags
```

---

## 🎯 Usage Examples

### Example 1: Display in List
```dart
Image.network(
  manga.getThumbnailUrl(),
  width: 100,
  height: 150,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.book);
  },
)
```

### Example 2: Detail Screen with Background
```dart
Stack(
  children: [
    // Background
    Image.network(
      manga.getBackgroundUrl(quality: 'medium'),
      width: double.infinity,
      height: 300,
      fit: BoxFit.cover,
    ),
    // Cover overlay
    Positioned(
      left: 16,
      bottom: 16,
      child: Image.network(
        manga.getCoverUrlHQ(),
        width: 120,
        height: 180,
        fit: BoxFit.cover,
      ),
    ),
  ],
)
```

### Example 3: With Cached Network Image
```dart
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: manga.getCoverUrlHQ(),
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  fit: BoxFit.cover,
)
```

### Example 4: Display Metadata
```dart
Column(
  children: [
    Text(manga.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    if (manga.rating != null)
      Row(
        children: [
          Icon(Icons.star, color: Colors.amber),
          Text('${manga.rating}/10'),
        ],
      ),
    if (manga.views != null)
      Text('${manga.views} followers'),
    Text('Status: ${manga.status}'),
    if (manga.year != null)
      Text('Year: ${manga.year}'),
    Wrap(
      children: manga.tags.map((tag) => Chip(label: Text(tag))).toList(),
    ),
  ],
)
```

---

## 🔄 Image URL Format

MangaDex uses this URL format for covers:

```
https://uploads.mangadex.org/covers/{mangaId}/{coverArtId}.{quality}.jpg
```

**Quality values:**
- `256` - 256x256 pixels
- `512` - 512x512 pixels
- `medium` - ~300x300 pixels (default)
- `original` - Full resolution (varies)

---

## ⚡ Performance Tips

### 1. Use Appropriate Quality
```dart
// For thumbnails
manga.getThumbnailUrl(); // 256px

// For detail screens
manga.getCoverUrlHQ(); // 512px

// For full screen
manga.getCoverUrl(quality: 'original'); // Full res
```

### 2. Cache Images
```dart
// Use cached_network_image package
CachedNetworkImage(
  imageUrl: manga.getCoverUrlHQ(),
  cacheManager: CacheManager.instance,
)
```

### 3. Error Handling
```dart
Image.network(
  manga.getCoverUrlHQ(),
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.book),
    );
  },
)
```

---

## 📋 API Response Example

When you fetch a manga, you get:

```json
{
  "id": "manga-id-123",
  "attributes": {
    "title": { "en": "Manga Title" },
    "description": { "en": "..." },
    "status": "ongoing",
    "year": 2020,
    "contentRating": "suggestive",
    "stats": {
      "rating": { "average": 8.5 },
      "follows": 15000
    }
  },
  "relationships": [
    {
      "id": "cover-art-id",
      "type": "cover_art",
      "attributes": { "fileName": "cover.jpg" }
    }
  ]
}
```

---

## 🎨 Recommended UI Layout

### Detail Screen
```
┌─────────────────────────────┐
│  Background Image (blurred) │
│  ┌─────────────────────┐    │
│  │  Cover Image (HQ)   │    │
│  │  512x512px          │    │
│  └─────────────────────┘    │
│  Title                      │
│  ⭐ 8.5/10 | 15K followers  │
│  Status: Ongoing | 2020     │
│  Authors, Artists           │
│  Tags/Genres                │
│  Description...             │
│  [Chapters List]            │
└─────────────────────────────┘
```

### List/Grid
```
┌──────────┐  ┌──────────┐
│ Thumb    │  │ Thumb    │
│ 256x256  │  │ 256x256  │
│ Title    │  │ Title    │
└──────────┘  └──────────┘
```

---

## ✅ Checklist

- ✅ Cover images fetch from MangaDex
- ✅ Background images available
- ✅ Multiple quality options
- ✅ Metadata (rating, views, status) included
- ✅ Error handling with fallbacks
- ✅ Performance optimized with caching
- ✅ Ready for production

---

**Last Updated:** November 29, 2025
**Status:** ✅ Complete
**Version:** 2.4.0 (Image Fetching)
