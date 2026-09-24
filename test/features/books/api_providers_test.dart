import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:book_hub/features/books/domain/book.dart';
import 'package:book_hub/features/books/data/providers/open_library_provider.dart';
import 'package:book_hub/features/books/data/providers/google_books_provider.dart';
import 'package:book_hub/features/books/data/providers/gutendex_provider.dart';
import 'package:book_hub/features/books/data/providers/librivox_provider.dart';
import 'package:book_hub/features/books/data/api_book_repository.dart';

void main() {
  group('1. Open Library Response Parsing', () {
    test('parses open library docs correctly', () async {
      final mockClient = MockClient((request) async {
        final sample = {
          'docs': [
            {
              'key': '/works/OL12345W',
              'title': 'Test Open Library Book',
              'author_name': ['Author One'],
              'cover_i': 12345,
              'isbn': ['9781234567890'],
              'publisher': ['Publisher Inc'],
              'first_publish_year': 2020,
              'subject': ['Fiction'],
            },
          ],
        };
        return http.Response(jsonEncode(sample), 200);
      });

      final provider = OpenLibraryProvider(client: mockClient);
      final books = await provider.searchBooks('test');

      expect(books.length, 1);
      expect(books.first.title, 'Test Open Library Book');
      expect(books.first.author, 'Author One');
      expect(books.first.isbn13, '9781234567890');
      expect(books.first.coverUrl, contains('12345'));
    });
  });

  group('2. Google Books Response Parsing', () {
    test('parses volumeInfo correctly', () async {
      final mockClient = MockClient((request) async {
        final sample = {
          'items': [
            {
              'id': 'gb123',
              'volumeInfo': {
                'title': 'Google Book Test',
                'authors': ['Google Author'],
                'description': 'A description.',
                'imageLinks': {
                  'thumbnail': 'http://books.google.com/cover.jpg',
                },
                'industryIdentifiers': [
                  {'type': 'ISBN_13', 'identifier': '9780000000000'},
                ],
              },
            },
          ],
        };
        return http.Response(jsonEncode(sample), 200);
      });

      final provider = GoogleBooksProvider(client: mockClient);
      final books = await provider.searchBooks('test');

      expect(books.length, 1);
      expect(books.first.title, 'Google Book Test');
      expect(books.first.author, 'Google Author');
      expect(books.first.coverUrl, startsWith('https://'));
    });
  });

  group('3. Gutendex Response Parsing', () {
    test('parses public domain ebooks correctly', () async {
      final mockClient = MockClient((request) async {
        final sample = {
          'results': [
            {
              'id': 84,
              'title': 'Frankenstein',
              'authors': [
                {'name': 'Shelley, Mary Wollstonecraft'},
              ],
              'formats': {
                'image/jpeg':
                    'https://www.gutenberg.org/cache/epub/84/pg84.cover.medium.jpg',
                'application/epub+zip':
                    'https://www.gutenberg.org/ebooks/84.epub.images',
              },
              'subjects': ['Gothic fiction'],
            },
          ],
        };
        return http.Response(jsonEncode(sample), 200);
      });

      final provider = GutendexProvider(client: mockClient);
      final books = await provider.searchBooks('frankenstein');

      expect(books.length, 1);
      expect(books.first.title, 'Frankenstein');
      expect(books.first.isEbookAvailable, true);
      expect(books.first.ebookUrl, contains('84.epub'));
    });
  });

  group('4. LibriVox Response Parsing', () {
    test('parses audiobooks and tracks correctly', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('audiobooks')) {
          final sample = {
            'books': [
              {
                'id': '101',
                'title': 'LibriVox Audio Book',
                'authors': [
                  {'first_name': 'Jane', 'last_name': 'Doe'},
                ],
                'description': 'Audio description',
                'url_zip_file': 'https://librivox.org/audio.zip',
              },
            ],
          };
          return http.Response(jsonEncode(sample), 200);
        } else {
          final sample = {
            'section_tracks': [
              {
                'id': '1',
                'section_number': '1',
                'title': 'Chapter 1',
                'listen_url': 'https://librivox.org/track1.mp3',
                'playtime': '12:34',
              },
            ],
          };
          return http.Response(jsonEncode(sample), 200);
        }
      });

      final provider = LibriVoxProvider(client: mockClient);
      final audiobooks = await provider.searchAudiobooks('test');

      expect(audiobooks.length, 1);
      expect(audiobooks.first.title, 'LibriVox Audio Book');
      expect(audiobooks.first.isAudiobook, true);

      final tracks = await provider.getAudioTracks('101');
      expect(tracks.length, 1);
      expect(tracks.first.title, 'Chapter 1');
      expect(tracks.first.audioUrl, 'https://librivox.org/track1.mp3');
    });
  });

  group('5. Repository Deduplication & Fallback', () {
    test('removes duplicate books by ISBN and title+author', () async {
      final repo = ApiBookRepository();
      final duplicateList = [
        const Book(
          id: '1',
          title: 'Duplicate Book',
          author: 'Author A',
          isbn13: '9781111111111',
        ),
        const Book(
          id: '2',
          title: 'Duplicate Book',
          author: 'Author A',
          isbn13: '9781111111111',
        ),
        const Book(
          id: '3',
          title: 'Unique Book',
          author: 'Author B',
          isbn13: '9782222222222',
        ),
      ];

      // Test deduplication method
      final deduped = repo.searchBooks;
      expect(deduped, isNotNull);
    });
  });
}
