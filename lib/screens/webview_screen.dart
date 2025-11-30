import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as wv;
import 'package:url_launcher/url_launcher_string.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String? title;

  const WebViewScreen({super.key, required this.url, this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  // Only initialize and use WebViewController when not running on web.
  wv.WebViewController? _controller;
  bool _loading = true;
  bool _canGoBack = false;
  bool _canGoForward = false;

  void _updateNavState() async {
    if (_controller == null) return;
    final back = await _controller!.canGoBack();
    final forward = await _controller!.canGoForward();
    setState(() {
      _canGoBack = back;
      _canGoForward = forward;
    });
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = wv.WebViewController()
        ..setJavaScriptMode(wv.JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          wv.NavigationDelegate(
            onPageStarted: (_) => setState(() => _loading = true),
            onPageFinished: (_) {
              setState(() => _loading = false);
              _updateNavState();
            },
            onNavigationRequest: (req) => wv.NavigationDecision.navigate,
            onWebResourceError: (err) {
              // optional: show snackbar
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải trang: ${err.description}')));
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? widget.url;
    return Scaffold(
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
        actions: kIsWeb
            ? [
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'Mở ngoài',
                  onPressed: () => launchUrlString(widget.url, webOnlyWindowName: '_blank'),
                )
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _canGoBack
                      ? () async {
                          if (_controller != null) await _controller!.goBack();
                          _updateNavState();
                        }
                      : () => Navigator.of(context).maybePop(),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _canGoForward
                      ? () async {
                          if (_controller != null) await _controller!.goForward();
                          _updateNavState();
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () async {
                    if (_controller != null) await _controller!.reload();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => launchUrlString(widget.url, mode: LaunchMode.externalApplication),
                ),
              ],
      ),
      body: kIsWeb
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Trình duyệt web không hỗ trợ WebView nội bộ. Bạn có thể mở bài trong tab mới.'),
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
                if (_loading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.white70,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
    );
  }
}
