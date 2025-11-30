import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as wv;
import 'package:url_launcher/url_launcher_string.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  // Only initialize and use WebViewController when not running on web.
  wv.WebViewController? _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // On web, open in a new tab and show a fallback UI.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await launchUrlString(widget.url, webOnlyWindowName: '_blank');
      });
    } else {
      _controller = wv.WebViewController()
        ..setJavaScriptMode(wv.JavaScriptMode.unrestricted)
        ..setNavigationDelegate(wv.NavigationDelegate(onPageFinished: (_) => setState(() => _loading = false)))
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.url, overflow: TextOverflow.ellipsis)),
      body: kIsWeb
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Mở bài trong tab mới (trình duyệt).'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => launchUrlString(widget.url, webOnlyWindowName: '_blank'),
                    child: const Text('Mở bài đầy đủ'),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                if (_controller != null) wv.WebViewWidget(controller: _controller!) else const SizedBox.shrink(),
                if (_loading) const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}
