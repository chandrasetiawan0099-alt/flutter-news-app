import 'dart:convert';

class NewsModel {
  final String? sourceName;
  final String? author;
  final String? title;
  final String? description;
  final String? content;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;

  NewsModel({
    this.sourceName,
    this.author,
    this.title,
    this.description,
    this.content,
    this.url,
    this.urlToImage,
    this.publishedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    try {
      if (json['publishedAt'] != null) {
        parsedDate = DateTime.parse(json['publishedAt']).toLocal();
      }
    } catch (_) {
      parsedDate = null;
    }

    return NewsModel(
      sourceName:
          json['source'] != null ? json['source']['name'] as String? : null,
      author: json['author'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      content: json['content'] as String?,
      url: json['url'] as String?,
      urlToImage: json['urlToImage'] as String?,
      publishedAt: parsedDate,
    );
  }

  static List<NewsModel> listFromJson(String source) {
    final Map<String, dynamic> data = json.decode(source);
    if (data['articles'] == null) return [];
    return (data['articles'] as List)
        .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
