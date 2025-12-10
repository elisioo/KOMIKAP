# KOMIKAP

KOMIKAP is a manga reader app built with Flutter. It lets you discover, read, and manage your favorite manga in a single app, with online reading, saved titles, favorites, and offline downloads.

---

## Features

- **Browse & search manga**
- **View manga details and chapters**
- **Read chapters with an in-app reader**
- **Save manga to your library**
- **Mark favorites**
- **Download chapters for offline reading**

---

## Setup

1. **Prerequisites**
   - Flutter SDK installed
   - Android Studio or VS Code with Flutter/Dart plugins
   - Firebase project (for Auth & Firestore)

2. **Clone and install dependencies**

   ```bash
   git clone <your-repo-url>
   cd komikap
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project.
   - Add an Android app (e.g. `com.example.komikap`).
   - Download `google-services.json` and place it in `android/app/`.
   - Enable Authentication and Firestore in the Firebase console.

4. **Run the app**

   ```bash
   flutter run
   ```

---

## Usage

- **Sign in** using the Firebase authentication flow.
- **Browse / search manga** from the home/library screen.
- **Open a title** to see details and the chapter list.
- **Tap a chapter** to open the reader and start reading.
- **Save manga** to your library and mark them as favorites.
- **Download chapters** for offline reading from the downloads section.

---

## Database Schema (Overview)

### Firestore

- **Users collection**
  - Path: `users/{uid}`
  - Subcollection: `savedManga`
    - Path: `users/{uid}/savedManga/{mangaId}`
    - Stores saved manga for each user; favorites are tracked via a flag in the document.

> For exact document fields, see `lib/services/firebase_service.dart` and related model files.

### Local SQLite

- **Database**: `komikap_cache.db`
- **Key table**: `downloaded_chapters`
  - Stores metadata needed for offline chapters (e.g. chapter IDs and local paths).

---

## Screenshots

Add your app screenshots in this section.

[SCREENSHOT_PLACEHOLDER]

Replace `SCREENSHOT_PLACEHOLDER` with a Markdown image, for example:

```markdown
![Home Screen](assets/screenshots/home.png)
```

