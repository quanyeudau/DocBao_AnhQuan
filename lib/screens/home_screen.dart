import 'package:flutter/material.dart';

// imports trimmed: article/feed_source are provided by providers; not used directly here
import '../providers/bookmark_provider.dart';
import '../models/article.dart';
import '../providers/feed_provider.dart';
import '../screens/article_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/webview_screen.dart';
import '../screens/bookmarks_screen.dart';
import '../screens/manage_feeds_screen.dart';
import '../widgets/article_tile.dart';
import '../widgets/feed_tile.dart';
import 'article_search.dart';

class HomeScreen extends StatefulWidget {
  final FeedProvider feedProvider;
  final BookmarkProvider bookmarkProvider;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.feedProvider,
    required this.bookmarkProvider,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.feedProvider.fetchArticles();
  }

  String? _selectedCategoryId; // null means All
  List<Article> _filteredArticles(List<Article> all) {
    if (_selectedCategoryId == null || _selectedCategoryId == 'all') return all;
    return all.where((a) => a.sourceId == _selectedCategoryId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = widget.feedProvider;
    final bookmarkProvider = widget.bookmarkProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đọc Báo Online'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: ArticleSearchDelegate(widget.feedProvider.articles)),
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookmarksScreen(bookmarkProvider: bookmarkProvider))),
          ),
          IconButton(
            icon: const Icon(Icons.rss_feed),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManageFeedsScreen(feedProvider: feedProvider))),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsScreen(feedProvider: feedProvider, themeMode: widget.themeMode, onThemeChanged: widget.onThemeChanged))),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 96,
            child: AnimatedBuilder(
              animation: feedProvider,
              builder: (context, _) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  itemCount: feedProvider.feeds.length,
                  itemBuilder: (context, index) {
                    final f = feedProvider.feeds[index];
                    return SizedBox(
                      width: 300,
                      child: Card(
                        child: InkWell(
                          onTap: () => feedProvider.selectFeed(f),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FeedTile(feed: f),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Category chips (All + feeds)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _selectedCategoryId == null || _selectedCategoryId == 'all',
                    onSelected: (_) => setState(() => _selectedCategoryId = 'all'),
                  ),
                ),
                for (final f in feedProvider.feeds)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: ChoiceChip(
                      label: Text(f.title),
                      selected: _selectedCategoryId == f.id,
                      onSelected: (_) => setState(() => _selectedCategoryId = f.id),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: feedProvider,
              builder: (context, _) {
                if (feedProvider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final articles = feedProvider.articles;
                final displayed = _filteredArticles(articles);
                final lastError = feedProvider.lastError;
                if (displayed.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Không có bài. Nhấn để tải bài từ nguồn hiện tại.'),
                        if (lastError != null) ...[
                          const SizedBox(height: 8),
                          Text('Lỗi: ', style: Theme.of(context).textTheme.bodySmall),
                          Text(lastError, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                        ],
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: () => feedProvider.tryFetchWithFallback(), child: const Text('Tải bài')),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookmarksScreen(bookmarkProvider: bookmarkProvider))), child: const Text('Xem Bookmark')),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => feedProvider.fetchArticles(),
                  child: ListView.builder(
                    itemCount: displayed.length + 1,
                    itemBuilder: (context, idx) {
                      if (idx == displayed.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Center(
                            child: feedProvider.loading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: () => feedProvider.loadMore(),
                                    child: const Text('Xem thêm'),
                                  ),
                          ),
                        );
                      }

                      // Featured card for the first article
                      if (idx == 0) {
                        final a = displayed[0];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ArticleScreen(article: a))),
                            child: Hero(
                              tag: a.id,
                              child: Material(
                                borderRadius: BorderRadius.circular(14),
                                elevation: 4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (a.thumbnail != null && a.thumbnail!.isNotEmpty)
                                        Stack(
                                          children: [
                                            Image.network(a.thumbnail!, height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey.shade200)),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [Colors.transparent, Color.fromRGBO(0, 0, 0, 0.6)],
                                                  ),
                                                ),
                                                padding: const EdgeInsets.all(12),
                                                child: Text(a.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                              ),
                                            )
                                          ],
                                        )
                                      else
                                        Container(height: 160, color: Colors.grey.shade100, child: Padding(padding: const EdgeInsets.all(16.0), child: Text(a.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(child: Text(a.description, maxLines: 2, overflow: TextOverflow.ellipsis)),
                                            AnimatedBuilder(
                                              animation: bookmarkProvider,
                                              builder: (context, _) {
                                                final isBook = bookmarkProvider.isBookmarked(a);
                                                return Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(isBook ? Icons.bookmark : Icons.bookmark_border),
                                                      onPressed: () async {
                                                        if (isBook) {
                                                          await bookmarkProvider.remove(a);
                                                        } else {
                                                          await bookmarkProvider.add(a);
                                                        }
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.open_in_new),
                                                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WebViewScreen(url: a.link))),
                                                    )
                                                  ],
                                                );
                                              },
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      final a = displayed[idx];
                      return ArticleTile(
                        article: a,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ArticleScreen(article: a))),
                        trailing: AnimatedBuilder(
                          animation: bookmarkProvider,
                          builder: (context, _) {
                            final isBook = bookmarkProvider.isBookmarked(a);
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(isBook ? Icons.bookmark : Icons.bookmark_border),
                                  onPressed: () async {
                                    if (isBook) {
                                      await bookmarkProvider.remove(a);
                                    } else {
                                      await bookmarkProvider.add(a);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.open_in_new),
                                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WebViewScreen(url: a.link))),
                                )
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
