import 'api_client.dart';

class Book {
  const Book({
    required this.id,
    required this.title,
    this.author = '',
    this.coverUrl,
  });
  final int id;
  final String title;
  final String author;
  final String? coverUrl;

  factory Book.fromJson(Map<String, dynamic> json) {
    final authorsData = json['authors'] ?? json['author'];
    final String author;
    if (authorsData is List) {
      author = authorsData.join(', ');
    } else if (authorsData is String) {
      author = authorsData;
    } else {
      author = '';
    }

    return Book(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      author: author,
      coverUrl: json['cover_url']?.toString(),
    );
  }
}

class BookRepository {
  const BookRepository(this._api);
  final ApiClient _api;

  Future<List<Book>> search(String query) async {
    final response = await _api.get(
      '/api/v1/books/search?q=${Uri.encodeQueryComponent(query)}',
    );
    if (response is! List) return [];
    return response
        .whereType<Map<String, dynamic>>()
        .map((item) => Book.fromJson(item))
        .toList();
  }
}
