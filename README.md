# CineScope - Movie & TV Show Explorer

CineScope is a Flutter app for discovering TV shows and movies, viewing their
details, and saving a personal collection with notes and watch status. It uses
the **free public TVMaze API** and works without any API key, account, backend,
or paid service.

## Features

- Animated splash screen with a dark cinematic theme.
- Dark Material 3 UI with responsive layouts for phones, tablets, and desktop.
- Browse shows in a responsive card grid with poster, title, rating, genres,
  release year, and details.
- Debounced search (450 ms) against the TVMaze search endpoint.
- Details screen with a large poster, summary, genres, network, runtime,
  premiere date, and more.
- Infinite scrolling through TVMaze show pages.
- Pull-to-refresh.
- Favorites / personal collection with quick bookmark buttons.
- Local CRUD with Hive:
  - add shows to the collection,
  - edit notes and watch status,
  - remove saved shows.
- Offline caching of previously fetched pages, searches, and show details.
- Loading, error, empty, and offline states.
- Unit and widget tests.

## API

No key or registration is needed.

| Purpose         | Endpoint                    |
| --------------- | --------------------------- |
| Browse shows    | `GET /shows?page={page}`    |
| Search shows    | `GET /search/shows?q={text}`|
| Show details    | `GET /shows/{id}`           |

Base URL: `https://api.tvmaze.com`

Data and images are provided by [TVMaze](https://www.tvmaze.com/).

## Tech Stack

- Flutter / Dart
- Dio
- Hive + hive_flutter
- cached_network_image
- connectivity_plus

## Architecture

The app uses a simple **Repository Pattern**:

```text
UI (screens/widgets)
        |
        v
ShowRepository  --->  TvMazeApi (Dio)  --->  TVMaze API
        |           \--> HiveShowCache   --->  local cache
        |
        v
ConnectivityService (connectivity_plus)

CollectionRepository  --->  Hive collection box
        ^
        |
UI listens with ListenableBuilder
```

- `ShowRepository` is the single source of truth for remote show data. It checks
  connectivity, fetches from TVMaze when online, writes successful responses to
  Hive, and falls back to cached data when offline or when a request fails.
- `CollectionRepository` is the single source of truth for the user's saved
  shows. It exposes add, read, update, delete, and toggle operations and extends
  `ChangeNotifier` so all screens update automatically.
- Screens never call Dio or Hive directly. This keeps UI code small and makes the
  project easy to explain in a viva.
- Hive stores collection entries and cache entries as JSON strings. This avoids
  generated adapters and `build_runner`, keeping the project beginner-friendly.

### Folder Structure

```text
lib/
  main.dart                     # Hive init, dependency wiring, runApp
  app.dart                      # MaterialApp + theme + splash entry
  core/
    constants/app_constants.dart
    network/dio_client.dart     # Shared Dio configuration
    theme/app_theme.dart        # Dark Material 3 theme
    utils/text_utils.dart       # HTML stripping and date formatting
  data/
    models/
      app_exception.dart        # Friendly app/offline exceptions
      show.dart                 # TVMaze show model
      show_page.dart            # Paginated repository result
      saved_show.dart           # Hive collection model + WatchStatus
    repositories/
      show_repository.dart      # Remote + cache logic
      collection_repository.dart# Local CRUD + change notifications
    services/
      app_storage.dart          # Opens Hive boxes
      connectivity_service.dart # connectivity_plus wrapper
      hive_show_cache.dart      # Offline JSON cache
      tvmaze_api.dart           # Dio calls to TVMaze
  presentation/
    screens/
      splash_screen.dart
      home_shell.dart           # Bottom nav / NavigationRail
      explore_screen.dart       # Browse, search, pagination, refresh
      details_screen.dart
      collection_screen.dart
    widgets/
      show_card.dart
      show_poster.dart
      rating_badge.dart
      watch_status_chip.dart
      collection_dialogs.dart
      state_views.dart          # Loading/error/empty/offline UI
test/
  helpers/fakes.dart
  models/
  repositories/
  widgets/
```

## How Offline Caching Works

1. When a page, search, or details request succeeds, the JSON is stored in the
   `cinescope_cache` Hive box under a stable key such as `shows_page_0`,
   `search_dark`, or `show_1`.
2. Before every request, `ConnectivityService` checks the connection.
3. If offline, the repository reads the matching Hive entry. If it exists, the
   UI receives it with `fromCache = true` and shows an offline banner.
4. If online but the request fails, the repository also falls back to cache.
5. If no cache exists, the app shows a friendly error or offline state with a
   retry button.

The user's collection is stored separately in `cinescope_collection`, so saved
shows, notes, and watch status always remain available offline.

## Getting Started

### Requirements

- Flutter stable (developed with Flutter 3.47 and Dart 3.13)
- Android Studio / Xcode / VS Code with a connected device or emulator
- Internet access for TVMaze requests

### Install

```bash
flutter pub get
```

### Run

```bash
flutter run
```

You can choose a device with:

```bash
flutter devices
flutter run -d <device_id>
```

### Analyze and Test

```bash
flutter analyze
flutter test
```

## Build an APK

```bash
flutter build apk --release
```

The APK is written to:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For a smaller, ABI-specific APK:

```bash
flutter build apk --release --split-per-abi
```

The Android manifest already includes the `INTERNET` permission required for
release builds. The default Flutter template signs release builds with the debug
key; configure a proper keystore before publishing to Google Play.

If Flutter reports that plugin symlinks are unavailable on Windows, enable
Windows Developer Mode, then run the build again.

## Notes for a Viva

- **Repository Pattern:** UI asks repositories for data; repositories decide
  between TVMaze and Hive. This separates presentation from data access.
- **Debounce:** `_onQueryChanged` cancels the previous `Timer`, so the API is only
  called after the user stops typing for 450 ms. A request counter ignores stale
  responses.
- **Infinite scrolling:** the explore scroll listener loads the next TVMaze page
  near the bottom. Duplicate IDs are filtered before appending.
- **Offline-first fallback:** successful responses are cached in Hive; failures
  transparently fall back to cached JSON.
- **Reactive local data:** `CollectionRepository` extends `ChangeNotifier`, and
  `ListenableBuilder` rebuilds bookmark icons, the details actions, and the
  collection list when Hive data changes.
- **Responsive design:** `SliverGridDelegateWithMaxCrossAxisExtent` adapts the
  grid, details use a row on wide screens, and the shell switches between a
  bottom `NavigationBar` and a `NavigationRail`.

## License / Attribution

This is an educational project. Show metadata and images are provided by the
free TVMaze API. Please respect TVMaze's terms of use.
