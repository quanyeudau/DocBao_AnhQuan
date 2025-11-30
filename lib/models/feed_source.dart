class FeedSource {
  final String id;
  final String title;
  final String url;

  FeedSource({required this.id, required this.title, required this.url});

  factory FeedSource.fromJson(Map<String, dynamic> json) {
    return FeedSource(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
      };
}
