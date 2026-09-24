import '../../../data/api_client.dart';
import '../domain/book.dart';
import 'book_repository.dart';

class FastApiBookRepository implements BookRepository {
  const FastApiBookRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<Book>> searchBooks(String query) async {
    final response = await _client.get(
      '/api/v1/books/search?q=${Uri.encodeQueryComponent(query)}',
    );
    return (response as List).map((json) {
      final item = json as Map<String, dynamic>;
      return Book(
        id: item['id'] as int,
        title: item['title'] as String,
        author: (item['authors'] as List?)?.join(', ') ?? 'Unknown author',
        description: item['description'] as String? ?? '',
        coverUrl: item['cover_url'] as String?,
        genre: _firstGenre(item['genres']),
      );
    }).toList();
  }

  @override
  Future<Book?> getBookDetails(dynamic id) async {
    final item = await _client.get('/api/v1/books/$id') as Map<String, dynamic>;
    final result = await searchBooks(item['title'] as String);
    for (final book in result) {
      if (book.id == id) return book;
    }
    return null;
  }

  @override
  Future<List<Book>> getRecommendations() => searchBooks('');

  String _firstGenre(dynamic genres) {
    if (genres is List && genres.isNotEmpty) return genres.first.toString();
    return 'Fiction';
  }
}
