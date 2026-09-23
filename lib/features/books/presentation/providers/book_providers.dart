import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/book_repository.dart';
import '../../domain/book.dart';

final bookRepositoryProvider = Provider<BookRepository>(
  (ref) => MockBookRepository(),
);
final bookSearchProvider = FutureProvider.family<List<Book>, String>(
  (ref, query) => ref.watch(bookRepositoryProvider).searchBooks(query),
);
final recommendationsProvider = FutureProvider<List<Book>>(
  (ref) => ref.watch(bookRepositoryProvider).getRecommendations(),
);
