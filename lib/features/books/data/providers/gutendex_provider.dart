import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/book.dart';

class GutendexProvider {
  final http.Client _client;
  GutendexProvider({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://gutendex.com';

  Future<List<Book>> searchBooks(String query, {int page = 1}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/books?search=${Uri.encodeQueryComponent(query)}&page=$page',
      );
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];

        return results
            .map((item) => _mapGutenbergToBook(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Book _mapGutenbergToBook(Map<String, dynamic> item) {
    final id = item['id']?.toString() ?? '';
    final title = item['title']?.toString() ?? 'Untitled';

    final authorsList = item['authors'] as List<dynamic>?;
    final authorNames = authorsList != null
        ? authorsList
              .map((a) => a['name']?.toString())
              .whereType<String>()
              .toList()
        : <String>[];
    final author = authorNames.isNotEmpty
        ? authorNames.join(', ')
        : 'Public Domain';

    final formats = item['formats'] as Map<String, dynamic>? ?? {};
    final coverUrl = formats['image/jpeg']?.toString();

    final ebookUrl =
        formats['application/epub+zip']?.toString() ??
        formats['text/html']?.toString() ??
        formats['text/plain; charset=us-ascii']?.toString() ??
        formats['text/plain']?.toString();

    final subjects = item['subjects'] as List<dynamic>?;
    final genre = subjects != null && subjects.isNotEmpty
        ? subjects.first.toString()
        : 'Classic';

    final languages = item['languages'] as List<dynamic>?;
    final language = languages != null && languages.isNotEmpty
        ? languages.first.toString()
        : 'en';

    return Book(
      id: 'gutenberg_$id',
      title: title,
      author: author,
      description:
          'Free public-domain ebook provided by Project Gutenberg via Gutendex.',
      coverUrl: coverUrl,
      genre: genre,
      language: language,
      source: 'gutendex',
      sourceId: id,
      ebookUrl: ebookUrl,
      isEbookAvailable: ebookUrl != null,
    );
  }
}
