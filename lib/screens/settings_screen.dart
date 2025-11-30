import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode (local preview)'),
            value: _dark,
            onChanged: (v) => setState(() => _dark = v),
          ),
          ListTile(
            title: const Text('Manage feeds'),
            leading: const Icon(Icons.rss_feed),
            onTap: () {
              // Navigate to manage feeds screen; find FeedProvider from ancestor by type is not used in this app,
              // so require caller to push ManageFeedsScreen with provider passed. We'll attempt to read it via
              // ModalRoute arguments or use Navigator to push a placeholder.
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const SizedBox.shrink()));
            },
          ),
          ListTile(
            title: const Text('About'),
            subtitle: const Text('DocBao sample app'),
          )
        ],
      ),
    );
  }
}
