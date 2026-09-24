import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/book.dart';

class OpenLibraryProvider {
  final http.Client _client;
  OpenLibraryProvider({http.Client? client})
    : _client = client ?? http.Client();

  static const String baseUrl = 'https://openlibrary.org';

  Future<List<Book>> searchBooks(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/search.json?q=${Uri.encodeQueryComponent(query)}&page=$page&limit=$limit',
      );
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final docs = data['docs'] as List<dynamic>? ?? [];

        return docs
            .map((doc) => _mapDocToBook(doc as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Book _mapDocToBook(Map<String, dynamic> doc) {
    final key = doc['key']?.toString().replaceAll('/works/', '') ?? '';
    final title = doc['title']?.toString() ?? 'Untitled';
    final authorsList = doc['author_name'] as List<dynamic>?;
    final author = authorsList != null && authorsList.isNotEmpty
        ? authorsList.join(', ')
        : 'Unknown Author';

    final coverI = doc['cover_i'];
    final coverUrl = coverI != null
        ? 'https://covers.openlibrary.org/b/id/$coverI-M.jpg'
        : null;

    final isbns = doc['isbn'] as List<dynamic>?;
    String? isbn13;
    String? isbn10;
    if (isbns != null) {
      for (final isbn in isbns) {
        final str = isbn.toString().replaceAll('-', '').trim();
        if (str.length == 13 && isbn13 == null) isbn13 = str;
        if (str.length == 10 && isbn10 == null) isbn10 = str;
      }
    }

    final publisherList = doc['publisher'] as List<dynamic>?;
    final publisher = publisherList != null && publisherList.isNotEmpty
        ? publisherList.first.toString()
        : null;

    final publishedDate = doc['first_publish_year']?.toString();

    final subjects = doc['subject'] as List<dynamic>?;
    final genre = subjects != null && subjects.isNotEmpty
        ? subjects.first.toString()
        : 'Fiction';

    return Book(
      id: key.isNotEmpty ? key : title.hashCode.toString(),
      title: title,
      author: author,
      description:
          doc['first_sentence']?.toString() ??
          'A compelling book available in the Open Library directory.',
      coverUrl: coverUrl,
      genre: genre,
      isbn10: isbn10,
      isbn13: isbn13,
      publisher: publisher,
      publishedDate: publishedDate,
      source: 'open_library',
      sourceId: key,
    );
  }
}
