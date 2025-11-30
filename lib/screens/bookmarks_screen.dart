import 'package:flutter/material.dart';

import '../providers/bookmark_provider.dart';
import '../screens/article_screen.dart';
import '../widgets/article_tile.dart';

class BookmarksScreen extends StatelessWidget {
  final BookmarkProvider bookmarkProvider;

  const BookmarksScreen({super.key, required this.bookmarkProvider});

  @override
  Widget build(BuildContext context) {
    final items = bookmarkProvider.bookmarks;
    return Scaffold(
      appBar: AppBar(title: const Text('Đã lưu')),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bookmark_border, size: 56, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Chưa có bài đã lưu', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Quay lại đọc tin'),
                  )
                ],
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, idx) {
                final a = items[idx];
                return ArticleTile(
                  article: a,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ArticleScreen(article: a))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ArticleScreen(article: a))),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever),
                        onPressed: () async {
                          await bookmarkProvider.remove(a);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
