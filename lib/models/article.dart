import 'dart:convert';

class Article {
  final String id;
  final String title;
  final String link;
  final String description;
  final String? thumbnail;
  final DateTime? pubDate;
  final String? content;

  Article({
    required this.id,
    required this.title,
    required this.link,
    required this.description,
    this.thumbnail,
    this.pubDate,
    this.content,
  });

  Article copyWith({
    String? id,
    String? title,
    String? link,
    String? description,
    String? thumbnail,
    DateTime? pubDate,
    String? content,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      pubDate: pubDate ?? this.pubDate,
      content: content ?? this.content,
    );
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      link: json['link'] as String,
      description: json['description'] as String,
      thumbnail: json['thumbnail'] as String?,
      pubDate: json['pubDate'] != null ? DateTime.tryParse(json['pubDate']) : null,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'link': link,
        'description': description,
        'thumbnail': thumbnail,
        'pubDate': pubDate?.toIso8601String(),
        'content': content,
      };

  @override
  String toString() => jsonEncode(toJson());
}
