import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

import '../models/article.dart';
import '../models/feed_source.dart';

/// RSS service using `http` and `webfeed` for parsing.
/// Supports simple caching to a provided cache directory (optional).
class RssService {
  final http.Client _client;
  /// Optional CORS proxy prefix used when running on web. Example: "https://api.allorigins.win/raw?url="
  final String? corsProxy;

  RssService({http.Client? client, this.corsProxy}) : _client = client ?? http.Client();
  /// Fetch and parse articles for a single feed URL.
  Future<List<Article>> fetchArticles(String url, {FeedSource? source}) async {
    try {
      // When running in web, many RSS endpoints block cross-origin requests.
      // If a corsProxy is provided (or defaulted), route requests through it.
      final effectiveUrl = (kIsWeb && (corsProxy != null && corsProxy!.isNotEmpty))
          ? '${corsProxy!}${Uri.encodeComponent(url)}'
          : url;
      final res = await _client.get(Uri.parse(effectiveUrl)).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) {
        throw HttpException('Status ${res.statusCode}');
      }
      final body = res.body;
      final feed = RssFeed.parse(body);
      return feed.items?.map((item) => _mapItem(item, source: source)).toList() ?? [];
    } catch (e) {
      // Propagate error to caller who can handle cache fallback.
      rethrow;
    }
  }

  /// Fetch articles for multiple sources concurrently.
  Future<Map<String, List<Article>>> fetchForSources(List<FeedSource> sources) async {
    final Map<String, List<Article>> result = {};
    final futures = sources.map((s) async {
      try {
        final list = await fetchArticles(s.url, source: s);
        result[s.id] = list;
      } catch (_) {
        result[s.id] = [];
      }
    });
    await Future.wait(futures);
    return result;
  }

  Article _mapItem(RssItem item, {FeedSource? source}) {
    final link = item.link ?? item.guid ?? '';
    final id = link.isNotEmpty ? link : '${DateTime.now().microsecondsSinceEpoch}';
    String description = item.description ?? '';
    // Some feeds use content:encoded or other content wrapper
    if ((description.isEmpty) && (item.content != null)) {
      description = item.content.toString();
    }

    DateTime? parsedDate;
    if (item.pubDate != null) {
      if (item.pubDate is String) {
        parsedDate = DateTime.tryParse(item.pubDate as String);
      } else if (item.pubDate is DateTime) {
        parsedDate = item.pubDate as DateTime;
      }
    }

    String? thumbnail;
    if (item.enclosure?.url != null && (item.enclosure!.url ?? '').isNotEmpty) {
      thumbnail = item.enclosure!.url;
    }

    return Article(
      id: id,
      title: item.title ?? 'No title',
      link: link,
      description: _stripTags(description),
      pubDate: parsedDate,
      content: item.content?.toString(),
      thumbnail: thumbnail,
    );
  }

  String _stripTags(String input) => input.replaceAll(RegExp(r'<[^>]*>'), '').trim();
}
