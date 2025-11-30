import 'package:flutter/material.dart';

import '../models/feed_source.dart';
import '../providers/feed_provider.dart';

class ManageFeedsScreen extends StatefulWidget {
  final FeedProvider feedProvider;

  const ManageFeedsScreen({super.key, required this.feedProvider});

  @override
  State<ManageFeedsScreen> createState() => _ManageFeedsScreenState();
}

class _ManageFeedsScreenState extends State<ManageFeedsScreen> {
  Future<void> _showEditDialog({FeedSource? source}) async {
    final titleCtrl = TextEditingController(text: source?.title ?? '');
    final urlCtrl = TextEditingController(text: source?.url ?? '');
    final isNew = source == null;

    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isNew ? 'Thêm nguồn' : 'Sửa nguồn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề')),
            TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () {
              final t = titleCtrl.text.trim();
              final u = urlCtrl.text.trim();
              if (t.isEmpty || u.isEmpty) return;
              final id = source?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
              final f = FeedSource(id: id, title: t, url: u);
              if (isNew) {
                widget.feedProvider.addFeed(f);
              } else {
                widget.feedProvider.updateFeed(f);
              }
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Lưu'),
          )
        ],
      ),
    );
    if (res == true) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.feedProvider;
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý nguồn')), 
      body: AnimatedBuilder(
        animation: provider,
        builder: (context, _) {
          final feeds = provider.feeds;
          if (feeds.isEmpty) return const Center(child: Text('Chưa có nguồn nào'));
          return ListView.builder(
            itemCount: feeds.length,
            itemBuilder: (context, i) {
              final f = feeds[i];
              return ListTile(
                title: Text(f.title),
                subtitle: Text(f.url),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(onPressed: () => _showEditDialog(source: f), icon: const Icon(Icons.edit)),
                    IconButton(onPressed: () => provider.removeFeed(f.id), icon: const Icon(Icons.delete)),
                  ],
                ),
                onTap: () {
                  provider.selectFeed(f);
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
