import 'dart:async';
import '../domain/book.dart';
import 'book_repository.dart';
import 'providers/open_library_provider.dart';
import 'providers/google_books_provider.dart';
import 'providers/gutendex_provider.dart';
import 'providers/librivox_provider.dart';

class ApiBookRepository implements BookRepository {
  final OpenLibraryProvider _openLibraryProvider;
  final GoogleBooksProvider _googleBooksProvider;
  final GutendexProvider _gutendexProvider;
  final LibriVoxProvider _libriVoxProvider;

  ApiBookRepository({
    OpenLibraryProvider? openLibraryProvider,
    GoogleBooksProvider? googleBooksProvider,
    GutendexProvider? gutendexProvider,
    LibriVoxProvider? libriVoxProvider,
  }) : _openLibraryProvider = openLibraryProvider ?? OpenLibraryProvider(),
       _googleBooksProvider = googleBooksProvider ?? GoogleBooksProvider(),
       _gutendexProvider = gutendexProvider ?? GutendexProvider(),
       _libriVoxProvider = libriVoxProvider ?? LibriVoxProvider();

  final Map<String, List<Book>> _searchCache = {};
  final Map<String, Book> _bookCache = {};

  @override
  Future<List<Book>> searchBooks(String query) async {
    final trimmed = query.trim().toLowerCase();
    if (_searchCache.containsKey(trimmed)) {
      return _searchCache[trimmed]!;
    }

    final List<Book> combined = [];

    final searchTerm = trimmed.isEmpty ? 'classic fiction' : query;

    // 1. Primary: Open Library
    List<Book> openLibResults = [];
    try {
      openLibResults = await _openLibraryProvider.searchBooks(searchTerm);
    } catch (_) {}

    // 2. Fallback: Google Books if Open Library returns empty or fails
    if (openLibResults.isEmpty) {
      try {
        openLibResults = await _googleBooksProvider.searchBooks(searchTerm);
      } catch (_) {}
    }

    combined.addAll(openLibResults);

    // 3. Gutendex for public domain ebooks
    try {
      final gutenbergResults = await _gutendexProvider.searchBooks(searchTerm);
      combined.addAll(gutenbergResults);
    } catch (_) {}

    // 4. LibriVox for audiobooks
    try {
      final libriVoxResults = await _libriVoxProvider.searchAudiobooks(
        searchTerm,
      );
      combined.addAll(libriVoxResults);
    } catch (_) {}

    // 5. Deduplicate results
    final deduped = _deduplicateBooks(combined);

    // Cache results
    for (final book in deduped) {
      _bookCache[book.id.toString()] = book;
    }
    _searchCache[trimmed] = deduped;

    return deduped;
  }

  @override
  Future<Book?> getBookDetails(dynamic id) async {
    final idStr = id.toString();
    if (_bookCache.containsKey(idStr)) {
      final cachedBook = _bookCache[idStr]!;
      // If it's a LibriVox audiobook and tracks aren't loaded yet, fetch tracks
      if (cachedBook.isAudiobook && cachedBook.tracks.isEmpty) {
        try {
          final tracks = await _libriVoxProvider.getAudioTracks(idStr);
          final updated = Book(
            id: cachedBook.id,
            title: cachedBook.title,
            author: cachedBook.author,
            description: cachedBook.description,
            coverUrl: cachedBook.coverUrl,
            genre: cachedBook.genre,
            progress: cachedBook.progress,
            isAudiobook: true,
            coverColor: cachedBook.coverColor,
            isbn10: cachedBook.isbn10,
            isbn13: cachedBook.isbn13,
            publisher: cachedBook.publisher,
            publishedDate: cachedBook.publishedDate,
            pageCount: cachedBook.pageCount,
            language: cachedBook.language,
            source: cachedBook.source,
            sourceId: cachedBook.sourceId,
            ebookUrl: cachedBook.ebookUrl,
            isEbookAvailable: cachedBook.isEbookAvailable,
            audioUrl: cachedBook.audioUrl,
            tracks: tracks,
          );
          _bookCache[idStr] = updated;
          return updated;
        } catch (_) {}
      }
      return cachedBook;
    }

    // Attempt searching in Open Library / Google Books / LibriVox by ID
    final results = await searchBooks(idStr);
    if (results.isNotEmpty) {
      return results.first;
    }

    return null;
  }

  @override
  Future<List<Book>> getRecommendations() async {
    if (_searchCache.containsKey('__recommendations__')) {
      return _searchCache['__recommendations__']!;
    }

    final recommendations = await searchBooks('fiction');
    _searchCache['__recommendations__'] = recommendations;
    return recommendations;
  }

  List<Book> _deduplicateBooks(List<Book> books) {
    final Set<String> seenIsbns = {};
    final Set<String> seenTitles = {};
    final Set<String> seenIds = {};

    final List<Book> uniqueBooks = [];

    for (final book in books) {
      final idStr = book.id.toString();
      if (seenIds.contains(idStr)) continue;

      if (book.isbn13 != null && book.isbn13!.isNotEmpty) {
        if (seenIsbns.contains(book.isbn13)) continue;
        seenIsbns.add(book.isbn13!);
      }

      if (book.isbn10 != null && book.isbn10!.isNotEmpty) {
        if (seenIsbns.contains(book.isbn10)) continue;
        seenIsbns.add(book.isbn10!);
      }

      final normalizedTitleAuthor =
          '${book.title.trim().toLowerCase()}_${book.author.trim().toLowerCase()}';
      if (seenTitles.contains(normalizedTitleAuthor)) continue;

      seenIds.add(idStr);
      seenTitles.add(normalizedTitleAuthor);
      uniqueBooks.add(book);
    }

    return uniqueBooks;
  }
}
