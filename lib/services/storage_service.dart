import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

/// Storage service using SharedPreferences for bookmarks and file cache for feeds.
class StorageService {
  static const _bookmarksKey = 'bookmarks_v1';

  Future<void> saveBookmarks(List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final json = articles.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_bookmarksKey, json);
  }

  Future<List<Article>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_bookmarksKey) ?? <String>[];
    try {
      return list.map((s) => Article.fromJson(Map<String, dynamic>.from(jsonDecode(s)))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFeedCache(String feedId, List<Article> articles) async {
    // Feed caching removed per project settings (VSS); no-op.
    return Future.value();
  }

  Future<List<Article>> loadFeedCache(String feedId) async {
    try {
      // Feed cache disabled — return empty so callers fall back to network.
      return [];
    } catch (_) {
      return [];
    }
  }
  // Feed list persistence removed per project settings (VSS). No-op helper methods could be added later if needed.
}
