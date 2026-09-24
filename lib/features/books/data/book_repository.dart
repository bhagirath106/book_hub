import '../domain/book.dart';

abstract interface class BookRepository {
  Future<List<Book>> searchBooks(String query);
  Future<Book?> getBookDetails(dynamic id);
  Future<List<Book>> getRecommendations();
}
