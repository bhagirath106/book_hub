import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/api_client.dart';
import 'data/book_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final bookRepositoryProvider = Provider<BookRepository>(
  (ref) => BookRepository(ref.watch(apiClientProvider)),
);
final bookSearchProvider = FutureProvider.family<List<Book>, String>((ref, query) {
  return ref.watch(bookRepositoryProvider).search(query);
});
