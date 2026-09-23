import '../domain/book.dart';

abstract interface class BookRepository {
  Future<List<Book>> searchBooks(String query);
  Future<Book?> getBookDetails(int id);
  Future<List<Book>> getRecommendations();
}

class MockBookRepository implements BookRepository {
  static const _books = [
    Book(
      id: 1,
      title: 'The Salt Road',
      author: 'Jane Harper',
      genre: 'Adventure',
      description: 'A vivid journey across a changing landscape.',
      coverColor: 0xffefa936,
    ),
    Book(
      id: 2,
      title: 'Atomic Habits',
      author: 'James Clear',
      genre: 'Non-fiction',
      description: 'Tiny changes, remarkable results.',
      coverColor: 0xffc96e2f,
    ),
    Book(
      id: 3,
      title: 'The Night Circus',
      author: 'Erin Morgenstern',
      genre: 'Fantasy',
      description: 'A mysterious circus arrives without warning.',
      coverColor: 0xff82b36c,
    ),
    Book(
      id: 4,
      title: 'Pachinko',
      author: 'Min Jin Lee',
      genre: 'Historical',
      description: 'A sweeping story of family and belonging.',
      coverColor: 0xff985544,
    ),
    Book(
      id: 5,
      title: 'The Creative Act',
      author: 'Rick Rubin',
      genre: 'Creativity',
      description: 'A way of being and making.',
      coverColor: 0xff342a24,
      isAudiobook: true,
    ),
  ];
  @override
  Future<List<Book>> searchBooks(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (query.trim().isEmpty) return _books;
    final normalized = query.toLowerCase();
    return _books
        .where(
          (book) => '${book.title} ${book.author} ${book.genre}'
              .toLowerCase()
              .contains(normalized),
        )
        .toList();
  }

  @override
  Future<Book?> getBookDetails(int id) async {
    for (final book in _books) {
      if (book.id == id) return book;
    }
    return null;
  }

  @override
  Future<List<Book>> getRecommendations() async => _books;
}
