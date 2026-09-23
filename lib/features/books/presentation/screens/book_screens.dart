import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/bookhub_widgets.dart';
import '../providers/book_providers.dart';
import '../../domain/book.dart';
import '../../../home/presentation/screens/home_screen.dart';

class SearchResultsScreen extends ConsumerWidget {
  const SearchResultsScreen({required this.query, super.key});
  final String query;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(bookSearchProvider(query));
    return Scaffold(
      appBar: AppBar(
        title: Text(query.isEmpty ? 'Search' : 'Results for “$query”'),
      ),
      body: results.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const EmptyState(
          title: 'Search unavailable',
          message: 'Check your connection and try again.',
        ),
        data: (items) => items.isEmpty
            ? const EmptyState(
                title: 'No matches',
                message: 'Try another title, author, or genre.',
                icon: Icons.search_off,
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (_, i) => _BookListTile(
                  book: items[i],
                  onTap: () => context.push('/books/${items[i].id}'),
                ),
              ),
      ),
    );
  }
}

class AdvancedFiltersScreen extends StatefulWidget {
  const AdvancedFiltersScreen({super.key});
  @override
  State<AdvancedFiltersScreen> createState() => _AdvancedFiltersScreenState();
}

class _AdvancedFiltersScreenState extends State<AdvancedFiltersScreen> {
  String type = 'All';
  String availability = 'Any';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Advanced filters')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Format', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: ['All', 'Book', 'Manga', 'Novel', 'Audiobook']
              .map(
                (value) => ChoiceChip(
                  label: Text(value),
                  selected: type == value,
                  onSelected: (_) => setState(() => type = value),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        const Text(
          'Availability',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: ['Any', 'Free', 'Paid', 'Borrow']
              .map(
                (value) => ChoiceChip(
                  label: Text(value),
                  selected: availability == value,
                  onSelected: (_) => setState(() => availability = value),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        const TextField(decoration: InputDecoration(labelText: 'Genre')),
        const SizedBox(height: 14),
        const TextField(decoration: InputDecoration(labelText: 'Author')),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.pop(),
          child: const Text('Apply filters'),
        ),
      ],
    ),
  );
}

class BookDetailsScreen extends ConsumerWidget {
  const BookDetailsScreen({required this.bookId, super.key});
  final int bookId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookRepositoryProvider).getBookDetails(bookId);
    return FutureBuilder<Book?>(
      future: book,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final item = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              Center(
                child: Hero(
                  tag: 'book-${item.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: SizedBox(
                      width: 190,
                      height: 260,
                      child: item.coverUrl == null
                          ? Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: const Icon(Icons.menu_book, size: 60),
                            )
                          : Image.network(item.coverUrl!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(item.author, textAlign: TextAlign.center),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  Chip(label: Text(item.genre)),
                  const Chip(label: Text('Available')),
                  const Chip(label: Text('4.8 ★')),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/reader/${item.id}'),
                      icon: const Icon(Icons.menu_book),
                      label: const Text('Read'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.collections_bookmark_outlined),
                      label: const Text('Library'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({required this.bookId, super.key});
  final int bookId;
  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  int page = 1;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AppBar(
      title: const Text('The Salt Road'),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.text_fields)),
      ],
    ),
    body: GestureDetector(
      onHorizontalDragEnd: (_) => setState(() => page++),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 18, 28, 40),
        children: [
          Text(
            'Chapter 12',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'The long road home',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          const Text(
            'The morning arrived quietly, gathering itself along the horizon. Every mile carried a new color, a new question, and the memory of all the pages that had come before.',
            style: TextStyle(fontSize: 19, height: 1.8),
          ),
          const SizedBox(height: 20),
          const Text(
            'She opened the book again, not because the ending had changed, but because she had. Reading was a small way of returning to the places that made us.',
            style: TextStyle(fontSize: 19, height: 1.8),
          ),
          const SizedBox(height: 32),
          LinearProgressIndicator(value: page / 20),
          const SizedBox(height: 8),
          Text('Page $page of 20', textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class AudiobooksScreen extends StatelessWidget {
  const AudiobooksScreen({super.key});
  @override
  Widget build(BuildContext context) => const _FeatureScreen(
    title: 'Audiobooks',
    icon: Icons.headphones,
    message: 'Your audio library will appear here.',
    route: '/audiobook/player',
  );
}

class AudiobookPlayerScreen extends StatelessWidget {
  const AudiobookPlayerScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Now playing')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.album, size: 150, color: Colors.deepPurple),
          const SizedBox(height: 24),
          Text(
            'The Salt Road',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Text('Chapter 12 · 18:42'),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: LinearProgressIndicator(value: .42),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.replay)),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.play_circle, size: 68),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.forward)),
            ],
          ),
        ],
      ),
    ),
  );
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context) => BookHubScaffold(
    title: 'My Library',
    selectedIndex: 2,
    body: const _LibraryBody(),
  );
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) => const _FeatureScreen(
    title: 'Favorites',
    icon: Icons.favorite,
    message: 'Books you love will be saved here.',
    route: '/discover',
  );
}

class ReadingHistoryScreen extends StatelessWidget {
  const ReadingHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => const _FeatureScreen(
    title: 'Reading history',
    icon: Icons.history,
    message: 'Your reading journey will appear here.',
    route: '/analytics',
  );
}

class ReadingAnalyticsScreen extends StatelessWidget {
  const ReadingAnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context) => const _FeatureScreen(
    title: 'Reading analytics',
    icon: Icons.insights,
    message: 'Track your time, streaks, and milestones.',
    route: '/library',
  );
}

class _LibraryBody extends StatelessWidget {
  const _LibraryBody();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Make space for stories',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 8,
        children: ['Currently reading', 'Want to read', 'Completed']
            .map(
              (x) => FilterChip(
                label: Text(x),
                selected: x == 'Currently reading',
                onSelected: (_) {},
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 100),
      const EmptyState(
        title: 'Your library is ready',
        message: 'Add a book to start building your collection.',
        icon: Icons.collections_bookmark,
      ),
    ],
  );
}

class _BookListTile extends StatelessWidget {
  const _BookListTile({required this.book, required this.onTap});
  final Book book;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(12),
      leading: Container(
        width: 56,
        height: 76,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.menu_book),
      ),
      title: Text(
        book.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('${book.author}\n${book.genre}'),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}

class _FeatureScreen extends StatelessWidget {
  const _FeatureScreen({
    required this.title,
    required this.icon,
    required this.message,
    required this.route,
  });
  final String title, message, route;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: EmptyState(title: title, message: message, icon: icon),
  );
}
