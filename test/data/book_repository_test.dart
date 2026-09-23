import 'package:flutter_test/flutter_test.dart';
import 'package:book_hub/data/book_repository.dart';

void main() {
  group('Book.fromJson', () {
    test('parses json with authors list correctly', () {
      final json = {
        'id': 101,
        'title': 'Test Book',
        'authors': ['Author One', 'Author Two'],
        'cover_url': 'http://example.com/cover.jpg',
      };
      final book = Book.fromJson(json);
      expect(book.id, 101);
      expect(book.title, 'Test Book');
      expect(book.author, 'Author One, Author Two');
      expect(book.coverUrl, 'http://example.com/cover.jpg');
    });

    test('handles null or missing fields gracefully', () {
      final json = <String, dynamic>{'id': 202, 'title': 'Minimal Book'};
      final book = Book.fromJson(json);
      expect(book.id, 202);
      expect(book.title, 'Minimal Book');
      expect(book.author, '');
      expect(book.coverUrl, isNull);
    });

    test('handles numeric id as double gracefully', () {
      final json = <String, dynamic>{'id': 303.0, 'title': 'Float ID Book'};
      final book = Book.fromJson(json);
      expect(book.id, 303);
    });
  });
}
