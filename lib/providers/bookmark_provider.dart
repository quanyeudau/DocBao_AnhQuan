import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../services/storage_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final StorageService _storage;

  final Map<String, Article> _bookmarks = {};

  BookmarkProvider({StorageService? storage}) : _storage = storage ?? StorageService() {
    _load();
  }

  Future<void> _load() async {
    final items = await _storage.loadBookmarks();
    for (final a in items) {
      _bookmarks[a.id] = a;
    }
    notifyListeners();
  }

  Future<void> _save() async {
    await _storage.saveBookmarks(_bookmarks.values.toList());
  }

  List<Article> get bookmarks => _bookmarks.values.toList(growable: false);

  bool isBookmarked(Article a) => _bookmarks.containsKey(a.id);

  Future<void> add(Article a) async {
    _bookmarks[a.id] = a;
    notifyListeners();
    await _save();
  }

  Future<void> remove(Article a) async {
    _bookmarks.remove(a.id);
    notifyListeners();
    await _save();
  }
}
