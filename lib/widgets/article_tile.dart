import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/article.dart';

class ArticleTile extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ArticleTile({super.key, required this.article, this.onTap, this.trailing});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('yyyy-MM-dd HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (article.thumbnail != null && article.thumbnail!.isNotEmpty)
                    ? Image.network(article.thumbnail!, width: 100, height: 72, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, width: 100, height: 72, child: const Icon(Icons.broken_image)))
                    : Container(width: 100, height: 72, color: Colors.grey.shade100, child: const Icon(Icons.image, color: Colors.grey)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(article.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDate(article.pubDate), style: Theme.of(context).textTheme.bodySmall),
                        if (trailing != null) trailing!,
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
