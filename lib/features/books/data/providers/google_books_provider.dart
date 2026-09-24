import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/book.dart';

class GoogleBooksProvider {
  final http.Client _client;
  GoogleBooksProvider({http.Client? client})
    : _client = client ?? http.Client();

  static const String baseUrl = 'https://www.googleapis.com/books/v1';

  static const apiKey = String.fromEnvironment('GOOGLE_BOOKS_API_KEY');

  Future<List<Book>> searchBooks(
    String query, {
    int startIndex = 0,
    int maxResults = 20,
  }) async {
    try {
      var url =
          '$baseUrl/volumes?q=${Uri.encodeQueryComponent(query)}&startIndex=$startIndex&maxResults=$maxResults';
      if (apiKey.isNotEmpty) {
        url += '&key=$apiKey';
      }

      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];

        return items
            .map((item) => _mapVolumeToBook(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Book _mapVolumeToBook(Map<String, dynamic> item) {
    final id = item['id']?.toString() ?? '';
    final volumeInfo = item['volumeInfo'] as Map<String, dynamic>? ?? {};

    final title = volumeInfo['title']?.toString() ?? 'Untitled';
    final authorsList = volumeInfo['authors'] as List<dynamic>?;
    final author = authorsList != null && authorsList.isNotEmpty
        ? authorsList.join(', ')
        : 'Unknown Author';

    final description =
        volumeInfo['description']?.toString() ?? 'No description available.';

    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
    String? coverUrl =
        imageLinks?['thumbnail']?.toString() ??
        imageLinks?['smallThumbnail']?.toString();
    if (coverUrl != null && coverUrl.startsWith('http:')) {
      coverUrl = coverUrl.replaceFirst('http:', 'https:');
    }

    final identifiers = volumeInfo['industryIdentifiers'] as List<dynamic>?;
    String? isbn10;
    String? isbn13;
    if (identifiers != null) {
      for (final idObj in identifiers) {
        final type = idObj['type']?.toString();
        final val = idObj['identifier']?.toString();
        if (type == 'ISBN_10') isbn10 = val;
        if (type == 'ISBN_13') isbn13 = val;
      }
    }

    final publisher = volumeInfo['publisher']?.toString();
    final publishedDate = volumeInfo['publishedDate']?.toString();
    final pageCount = volumeInfo['pageCount'] as int?;
    final language = volumeInfo['language']?.toString();

    final categories = volumeInfo['categories'] as List<dynamic>?;
    final genre = categories != null && categories.isNotEmpty
        ? categories.first.toString()
        : 'General';

    return Book(
      id: 'gb_$id',
      title: title,
      author: author,
      description: description,
      coverUrl: coverUrl,
      genre: genre,
      isbn10: isbn10,
      isbn13: isbn13,
      publisher: publisher,
      publishedDate: publishedDate,
      pageCount: pageCount,
      language: language,
      source: 'google_books',
      sourceId: id,
    );
  }
}
