import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/book_repository.dart';
import '../../data/fastapi_book_repository.dart';
import '../../domain/book.dart';
import '../../../../app/config/app_config.dart';
import '../../../../core/network/providers.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  if (AppConfig.useRemoteApi) {
    return FastApiBookRepository(ref.watch(apiClientProvider));
  }
  return MockBookRepository();
});
final bookSearchProvider = FutureProvider.family<List<Book>, String>(
  (ref, query) => ref.watch(bookRepositoryProvider).searchBooks(query),
);
final recommendationsProvider = FutureProvider<List<Book>>(
  (ref) => ref.watch(bookRepositoryProvider).getRecommendations(),
);
