import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:docbao/services/rss_service.dart';

void main() {
  test('RssService parses items from sample RSS', () async {
    final sample = '''<?xml version="1.0" encoding="UTF-8" ?>
    <rss version="2.0"><channel>
      <title>Sample Feed</title>
      <item>
        <title>Test Article</title>
        <link>https://example.com/article/1</link>
        <description><![CDATA[<p>Short description</p>]]></description>
        <pubDate>Wed, 01 Jan 2020 00:00:00 +0000</pubDate>
        <guid>https://example.com/article/1</guid>
      </item>
    </channel></rss>
    ''';

    final client = MockClient((request) async {
      return http.Response(sample, 200, headers: {'content-type': 'application/rss+xml'});
    });

    final service = RssService(client: client);
    final list = await service.fetchArticles('https://example.com/rss');
    expect(list, isNotEmpty);
    expect(list.first.title, contains('Test Article'));
    expect(list.first.link, contains('/article/1'));
  });
}
