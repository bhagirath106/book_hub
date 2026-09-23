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

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] as int,
    title: json['title'] as String,
    author: (json['authors'] as List?)?.join(', ') ?? '',
    coverUrl: json['cover_url'] as String?,
  );
}

class BookRepository {
  const BookRepository(this._api);
  final ApiClient _api;

  Future<List<Book>> search(String query) async {
    final response = await _api.get(
      '/api/v1/books/search?q=${Uri.encodeQueryComponent(query)}',
    );
    return (response as List)
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
