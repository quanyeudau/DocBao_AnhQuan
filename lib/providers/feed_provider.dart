import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../models/feed_source.dart';
import '../services/rss_service.dart';

class FeedProvider extends ChangeNotifier {
  final RssService _rssService;

  List<FeedSource> feeds = [];
  List<Article> articles = [];
  FeedSource? selectedFeed;
  bool loading = false;

  FeedProvider({RssService? rssService}) : _rssService = rssService ?? RssService() {
    _initSample();
  }

  void _initSample() {
    feeds = [
      FeedSource(id: 'vnexpress', title: 'VnExpress', url: 'https://vnexpress.net/rss/tin-moi-nhat.rss'),
      FeedSource(id: 'tuoitre', title: 'Tuoi Tre', url: 'https://tuoitre.vn/rss/tin-moi-nhat.rss'),
    ];
    selectedFeed = feeds.first;
  }

  // No persisted feed list — feeds are initialized from _initSample().

  String? lastError;

  Future<void> fetchArticles({FeedSource? feed, bool forceRefresh = false}) async {
    final f = feed ?? selectedFeed;
    if (f == null) return;
    loading = true;
    notifyListeners();
    try {
      lastError = null;
        final list = await _rssService.fetchArticles(f.url, source: f);
      articles = list;
  // No feed caching per project settings.
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Try fetch but return whether succeeded. Sets `lastError` on failure.
  Future<bool> tryFetchWithFallback({FeedSource? feed}) async {
    final f = feed ?? selectedFeed;
    if (f == null) return false;
    loading = true;
    notifyListeners();
    try {
      lastError = null;
        final list = await _rssService.fetchArticles(f.url, source: f);
      articles = list;
      return true;
    } catch (e) {
      // No feed cache fallback; surface the error so UI can show retry.
      lastError = e.toString();
      articles = [];
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void selectFeed(FeedSource f) {
    selectedFeed = f;
    notifyListeners();
    fetchArticles(feed: f);
  }

  /// Add a new feed. If id is duplicate, it will be ignored.
  void addFeed(FeedSource feed) {
    if (feeds.any((f) => f.id == feed.id)) return;
    feeds.add(feed);
    notifyListeners();
  }

  /// Remove a feed by id. If the removed feed was selected, select the first available.
  void removeFeed(String id) {
    feeds.removeWhere((f) => f.id == id);
    if (selectedFeed?.id == id) {
      selectedFeed = feeds.isNotEmpty ? feeds.first : null;
      if (selectedFeed != null) fetchArticles(feed: selectedFeed);
    }
    notifyListeners();
  }

  /// Update an existing feed (matched by id). If not found, it will be added.
  void updateFeed(FeedSource feed) {
    final idx = feeds.indexWhere((f) => f.id == feed.id);
    if (idx >= 0) {
      feeds[idx] = feed;
      if (selectedFeed?.id == feed.id) selectedFeed = feed;
    } else {
      feeds.add(feed);
    }
    notifyListeners();
  }

  /// Load more articles by fetching from other feeds and appending unique items.
  Future<void> loadMore() async {
    final currentIds = articles.map((a) => a.id).toSet();
    final others = feeds.where((f) => f.id != selectedFeed?.id).toList();
    if (others.isEmpty) return;
    loading = true;
    notifyListeners();
    try {
      final map = await _rssService.fetchForSources(others);
      final incoming = <Article>[];
      for (final list in map.values) {
        for (final a in list) {
          if (!currentIds.contains(a.id)) {
            incoming.add(a);
            currentIds.add(a.id);
          }
        }
      }
      articles = [...articles, ...incoming];
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
