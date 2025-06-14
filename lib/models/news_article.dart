/// Model class representing a news article
/// Contains all the necessary information for a news item
class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String author;
  final DateTime publishedAt;
  final String imageUrl;
  final String category;

  NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.author,
    required this.publishedAt,
    required this.imageUrl,
    required this.category,
  });

  /// Creates a NewsArticle from JSON data
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
    );
  }

  /// Converts NewsArticle to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'author': author,
      'publishedAt': publishedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  /// Creates a copy of this NewsArticle with optionally updated fields
  NewsArticle copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? author,
    DateTime? publishedAt,
    String? imageUrl,
    String? category,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      author: author ?? this.author,
      publishedAt: publishedAt ?? this.publishedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'NewsArticle(id: $id, title: $title, author: $author)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsArticle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
