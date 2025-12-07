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

  runApp(MyApp(feedProvider: feedProvider, bookmarkProvider: bookmarkProvider, storage: storage));
}

class MyApp extends StatefulWidget {
  final FeedProvider feedProvider;
  final BookmarkProvider bookmarkProvider;
  final StorageService storage;

  const MyApp({super.key, required this.feedProvider, required this.bookmarkProvider, required this.storage});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final s = await widget.storage.loadThemeModeString();
    setState(() {
      if (s == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (s == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
  }

  Future<void> _setTheme(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final str = mode == ThemeMode.dark ? 'dark' : (mode == ThemeMode.light ? 'light' : 'system');
    await widget.storage.saveThemeModeString(str);
  }

  @override
  Widget build(BuildContext context) {

    // New refined palette: teal-green seed for calm, modern look
    final seed = const Color(0xFF00695C); // deep teal
    final lightScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
    final darkScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      scaffoldBackgroundColor: lightScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 2,
        backgroundColor: lightScheme.primaryContainer,
        foregroundColor: lightScheme.onPrimaryContainer,
        surfaceTintColor: lightScheme.primary,
      ),
      // CardTheme removed to avoid SDK compatibility issues; default cards will inherit colorScheme
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: lightScheme.surface,
        textColor: lightScheme.onSurface,
        iconColor: lightScheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightScheme.primary,
          foregroundColor: lightScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightScheme.primary,
          side: BorderSide(color: lightScheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      iconTheme: IconThemeData(color: lightScheme.primary, size: 20),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: lightScheme.secondary, foregroundColor: lightScheme.onSecondary),
      textTheme: ThemeData.light().textTheme.apply(bodyColor: lightScheme.onSurface, displayColor: lightScheme.onSurface),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: darkScheme.surface,
      appBarTheme: AppBarTheme(centerTitle: true, elevation: 2, backgroundColor: darkScheme.primaryContainer, foregroundColor: darkScheme.onPrimaryContainer),
  // CardTheme removed for dark theme as well; use default card appearance from colorScheme
      listTileTheme: ListTileThemeData(tileColor: darkScheme.surface, textColor: darkScheme.onSurface, iconColor: darkScheme.secondary),
    );

    return MaterialApp(
      title: 'DocBao',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(feedProvider: widget.feedProvider, bookmarkProvider: widget.bookmarkProvider, themeMode: _themeMode, onThemeChanged: _setTheme),
    );
  }
}