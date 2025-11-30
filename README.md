# DocBao (sample Flutter RSS reader)

This project is a small Flutter RSS reader sample created as a skeleton.

## Features implemented
- Home: list of feeds and articles
- Article view: summary + open full article in WebView
- Settings screen (placeholder)
- Bookmarks: save/remove bookmarks (persisted via SharedPreferences)
- RSS fetching & parsing via `http` + `webfeed`
- Caching: feed JSON cached to temporary directory (via `path_provider`)
- Pull-to-refresh and "Load more" button to fetch additional articles from other feeds

## Libraries used
- http — network requests
- webfeed — RSS/Atom parsing
- webview_flutter — in-app WebView
- shared_preferences — bookmark persistence
- path_provider — cache directory for feed caching

## Feed URLs
- VnExpress: https://vnexpress.net/rss/tin-moi-nhat.rss
- Tuoi Tre: https://tuoitre.vn/rss/tin-moi-nhat.rss
- BBC Vietnamese: http://feeds.bbci.co.uk/vietnamese/rss.xml
- BBC Vietnamese: https://www.bbc.com/vietnamese/index.xml

## Project structure
- `lib/models` — data models (Article, FeedSource)
- `lib/services` — RssService, StorageService
- `lib/providers` — ChangeNotifier providers
- `lib/screens` — UI screens: Home, Article, Bookmarks, Settings, WebView
- `lib/widgets` — small widgets (ArticleTile, FeedTile)

## How to run
1. Make sure Flutter SDK is installed and set up.
2. From project root:
```powershell
flutter pub get
flutter run
```

## Testing
Unit tests are in `test/`. Run:
```powershell
flutter test
```

## Notes & Next steps
- Thumbnail extraction is basic (uses enclosure URL only). Consider parsing `content:encoded` or media tags for richer thumbnails.
- Cache expiry isn't implemented — consider adding TTL per feed.
- For production, use a database (sqflite/Hive) for caching and bookmarks when required.
# docbao

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
