import 'package:flutter/material.dart';

import '../providers/feed_provider.dart';
import 'manage_feeds_screen.dart';

class SettingsScreen extends StatelessWidget {
  final FeedProvider? feedProvider;

  const SettingsScreen({super.key, this.feedProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Manage feeds'),
            leading: const Icon(Icons.rss_feed),
            onTap: () {
              if (feedProvider != null) {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManageFeedsScreen(feedProvider: feedProvider!)));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở Manage feeds từ đây')));
              }
            },
          ),
        ],
      ),
    );
  }
}
