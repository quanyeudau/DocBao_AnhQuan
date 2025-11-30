import 'package:flutter/material.dart';

import 'providers/bookmark_provider.dart';
import 'providers/feed_provider.dart';
import 'screens/home_screen.dart';
import 'services/rss_service.dart';
import 'services/storage_service.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // When running on web, use a public CORS proxy for development to avoid browser CORS issues.
  final rss = RssService(corsProxy: kIsWeb ? 'https://api.allorigins.win/raw?url=' : null);
  final storage = StorageService();
  final feedProvider = FeedProvider(rssService: rss);
  final bookmarkProvider = BookmarkProvider(storage: storage);

  runApp(MyApp(feedProvider: feedProvider, bookmarkProvider: bookmarkProvider));
}

class MyApp extends StatelessWidget {
  final FeedProvider feedProvider;
  final BookmarkProvider bookmarkProvider;

  const MyApp({super.key, required this.feedProvider, required this.bookmarkProvider});

  @override
  Widget build(BuildContext context) {
    // A fresh, bright seed color for a light, airy look
    final seed = const Color(0xFF0A84FF); // bright blue
    final colorScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
  scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(centerTitle: true, elevation: 2, backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        ),
      ),
      textTheme: ThemeData.light().textTheme.apply(bodyColor: colorScheme.onSurface, displayColor: colorScheme.onSurface),
    );

    return MaterialApp(
      title: 'DocBao',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: HomeScreen(feedProvider: feedProvider, bookmarkProvider: bookmarkProvider),
    );
  }
}