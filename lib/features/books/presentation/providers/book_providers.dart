import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/book_repository.dart';
import '../../data/api_book_repository.dart';
import '../../domain/book.dart';

final apiBookRepositoryProvider = Provider<ApiBookRepository>((ref) {
  return ApiBookRepository();
});

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return ref.watch(apiBookRepositoryProvider);
});

final bookSearchProvider = FutureProvider.family<List<Book>, String>(
  (ref, query) => ref.watch(bookRepositoryProvider).searchBooks(query),
);

final recommendationsProvider = FutureProvider<List<Book>>(
  (ref) => ref.watch(bookRepositoryProvider).getRecommendations(),
);

final bookDetailsProvider = FutureProvider.family<Book?, dynamic>(
  (ref, id) => ref.watch(bookRepositoryProvider).getBookDetails(id),
);
