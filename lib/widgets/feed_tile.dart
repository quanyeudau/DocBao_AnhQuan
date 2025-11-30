import 'package:flutter/material.dart';

import '../models/feed_source.dart';

class FeedTile extends StatelessWidget {
  final FeedSource feed;
  final VoidCallback? onTap;

  const FeedTile({super.key, required this.feed, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.03), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.rss_feed, size: 18),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(feed.title, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
