import 'package:flutter/material.dart';

import '../models/article.dart';
import 'article_screen.dart';
import '../widgets/article_tile.dart';

class ArticleSearchDelegate extends SearchDelegate<void> {
  final List<Article> articles;

  ArticleSearchDelegate(this.articles);

  List<Article> _filter(String q) {
    final lower = q.toLowerCase();
    return articles.where((a) => a.title.toLowerCase().contains(lower) || a.description.toLowerCase().contains(lower)).toList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return const SizedBox.shrink();
    final results = _filter(query);
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, idx) {
        final a = results[idx];
        return ArticleTile(
          article: a,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ArticleScreen(article: a))),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _filter(query);
    if (results.isEmpty) return const Center(child: Text('Không có kết quả'));
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, idx) {
        final a = results[idx];
        return ArticleTile(
          article: a,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ArticleScreen(article: a))),
        );
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }
}
