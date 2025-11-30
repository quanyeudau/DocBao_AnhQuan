import 'package:flutter/material.dart';

import '../providers/feed_provider.dart';
import 'manage_feeds_screen.dart';

class SettingsScreen extends StatelessWidget {
  final FeedProvider? feedProvider;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsScreen({super.key, this.feedProvider, required this.themeMode, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('Chuyển giao diện sáng/tối'),
            value: themeMode == ThemeMode.dark,
            onChanged: (v) => onThemeChanged(v ? ThemeMode.dark : ThemeMode.light),
          ),
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
