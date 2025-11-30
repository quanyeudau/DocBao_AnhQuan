import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/article.dart';
import 'webview_screen.dart';

class ArticleScreen extends StatelessWidget {
  final Article article;

  const ArticleScreen({super.key, required this.article});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('yyyy-MM-dd HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.thumbnail != null && article.thumbnail!.isNotEmpty)
              Hero(
                tag: article.id,
                child: Image.network(article.thumbnail!, width: double.infinity, height: 230, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey.shade200)),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  if (article.pubDate != null) Text(_formatDate(article.pubDate), style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Text(article.description, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 20),
                  if (article.link.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Mở bài đầy đủ trên Web'),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WebViewScreen(url: article.link))),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
