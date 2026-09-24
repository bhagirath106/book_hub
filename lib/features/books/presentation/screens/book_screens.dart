import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/bookhub_widgets.dart';
import '../providers/book_providers.dart';
import '../providers/audio_player_provider.dart';
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
  final dynamic bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookDetailsProvider(bookId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
        ],
      ),
      body: bookAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const EmptyState(
          title: 'Details unavailable',
          message: 'Unable to load book details right now.',
        ),
        data: (item) {
          if (item == null) {
            return const EmptyState(
              title: 'Book not found',
              message: 'The requested book could not be found.',
              icon: Icons.error_outline,
            );
          }

          return ListView(
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
                  Chip(
                    label: Text(
                      item.isEbookAvailable
                          ? 'Free Ebook'
                          : item.isAudiobook
                          ? 'Audiobook'
                          : 'Available',
                    ),
                  ),
                  const Chip(label: Text('4.8 ★')),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                item.description.isNotEmpty
                    ? item.description
                    : 'A remarkable book to discover on BookHub.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        if (item.isAudiobook) {
                          ref
                              .read(audioPlayerProvider.notifier)
                              .loadAudiobook(item);
                          context.push('/audiobook/player');
                        } else {
                          context.push('/reader/${item.id}');
                        }
                      },
                      icon: Icon(
                        item.isAudiobook ? Icons.headphones : Icons.menu_book,
                      ),
                      label: Text(item.isAudiobook ? 'Listen' : 'Read'),
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
          );
        },
      ),
    );
  }
}

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({required this.bookId, super.key});
  final dynamic bookId;
  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  int page = 1;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AppBar(
      title: const Text('Book Reader'),
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
            'Chapter 1',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'The Journey Begins',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          const Text(
            'The morning arrived quietly, gathering itself along the horizon. Every mile carried a new color, a new question, and the memory of all the pages that had come before.',
            style: TextStyle(fontSize: 19, height: 1.8),
          ),
          const SizedBox(height: 20),
          const Text(
            'Reading connects us to timeless thoughts and stories across distant worlds.',
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

class AudiobooksScreen extends ConsumerWidget {
  const AudiobooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(bookSearchProvider('audiobook'));

    return Scaffold(
      appBar: AppBar(title: const Text('Audiobooks')),
      body: results.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const EmptyState(
          title: 'Audiobooks unavailable',
          message: 'Unable to load audiobooks right now.',
          icon: Icons.headphones,
        ),
        data: (items) {
          final audiobooks = items.where((b) => b.isAudiobook).toList();
          if (audiobooks.isEmpty) {
            return const EmptyState(
              title: 'No Audiobooks',
              message: 'Explore public domain audiobooks on LibriVox.',
              icon: Icons.headphones,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: audiobooks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final item = audiobooks[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.headphones, size: 28),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${item.author}\n${item.genre}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle_fill, size: 36),
                    onPressed: () {
                      ref
                          .read(audioPlayerProvider.notifier)
                          .loadAudiobook(item);
                      context.push('/audiobook/player');
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AudiobookPlayerScreen extends ConsumerWidget {
  const AudiobookPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioPlayerProvider);
    final notifier = ref.read(audioPlayerProvider.notifier);

    final book = playerState.currentBook;
    final currentTrack = playerState.currentTrack;

    final title = currentTrack?.title ?? book?.title ?? 'Now playing';
    final author = book?.author ?? 'LibriVox Audiobook';

    final pos = playerState.position;
    final dur = playerState.duration;
    final progress = (dur.inMilliseconds > 0)
        ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    String formatDuration(Duration d) {
      final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '${d.inHours > 0 ? '${d.inHours}:' : ''}$minutes:$seconds';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Now playing')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: book?.coverUrl != null
                      ? Image.network(book!.coverUrl!, fit: BoxFit.cover)
                      : Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(
                            Icons.album,
                            size: 100,
                            color: Colors.deepPurple,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(author, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              Slider(
                value: progress,
                onChanged: (val) {
                  final newPos = Duration(
                    milliseconds: (val * dur.inMilliseconds).round(),
                  );
                  notifier.seek(newPos);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDuration(pos)),
                    Text(formatDuration(dur)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 40,
                    onPressed: notifier.playPrevious,
                    icon: const Icon(Icons.skip_previous),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    iconSize: 68,
                    onPressed: notifier.togglePlayPause,
                    icon: Icon(
                      playerState.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    iconSize: 40,
                    onPressed: notifier.playNext,
                    icon: const Icon(Icons.skip_next),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
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
        child: book.coverUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(book.coverUrl!, fit: BoxFit.cover),
              )
            : const Icon(Icons.menu_book),
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
