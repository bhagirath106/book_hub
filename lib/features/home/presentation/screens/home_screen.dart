import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/bookhub_widgets.dart';
import '../../../books/presentation/providers/book_providers.dart';
import '../../../../app/theme/bookhub_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(recommendationsProvider);
    return BookHubScaffold(
      title: 'BookHub',
      selectedIndex: 0,
      floatingActionButton: AIButton(onPressed: () => context.push('/ai')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        children: [
          Text(
            'Your reading world',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Find a story worth getting lost in.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          TextField(
            controller: search,
            onSubmitted: (value) =>
                context.push('/search?q=${Uri.encodeQueryComponent(value)}'),
            decoration: const InputDecoration(
              hintText: 'Search books, authors, genres',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 26),
          _ContinueCard(onTap: () => context.push('/reader/1')),
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Recommended for you',
            action: () => context.push('/discover'),
          ),
          const SizedBox(height: 14),
          books.when(
            loading: () => const SizedBox(
              height: 190,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => const EmptyState(
              title: 'Offline mode',
              message: 'Your saved reading world is still available.',
            ),
            data: (items) => SizedBox(
              height: 270,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (_, index) => BookCard(
                  book: items[index],
                  onTap: () => context.push('/books/${items[index].id}'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          SectionHeader(title: 'Your activity'),
          const SizedBox(height: 12),
          Row(
            children: const [
              _StatCard(
                icon: Icons.local_fire_department,
                value: '7 days',
                label: 'streak',
              ),
              SizedBox(width: 12),
              _StatCard(
                icon: Icons.schedule,
                value: '4.2h',
                label: 'this week',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    color: BookHubColors.violet,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.menu_book, color: Colors.white, size: 42),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue reading',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'The Salt Road',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: .62,
                    color: Colors.white,
                    backgroundColor: Colors.white30,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: BookHubColors.gold),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label),
          ],
        ),
      ),
    ),
  );
}

class BookHubScaffold extends StatelessWidget {
  const BookHubScaffold({
    required this.body,
    this.title,
    this.selectedIndex = 0,
    this.floatingActionButton,
    super.key,
  });
  final Widget body;
  final String? title;
  final int selectedIndex;
  final Widget? floatingActionButton;
  static const destinations = [
    '/',
    '/discover',
    '/library',
    '/community',
    '/profile',
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: title == null ? null : Text(title!),
      actions: [
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: const Icon(Icons.notifications_none),
        ),
      ],
    ),
    body: body,
    floatingActionButton: floatingActionButton,
    bottomNavigationBar: NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => context.go(destinations[index]),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Discover',
        ),
        NavigationDestination(
          icon: Icon(Icons.collections_bookmark_outlined),
          selectedIcon: Icon(Icons.collections_bookmark),
          label: 'Library',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups),
          label: 'Community',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
  );
}

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => BookHubScaffold(
    title: 'Discover',
    selectedIndex: 1,
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Find your next favorite',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text('Explore stories across every genre.'),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              ['For you', 'Trending', 'Free', 'Audiobooks', 'Manga', 'Novels']
                  .map(
                    (label) => FilterChip(
                      label: Text(label),
                      selected: label == 'For you',
                      onSelected: (_) {},
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 28),
        SectionHeader(title: 'Trending now'),
        const SizedBox(height: 14),
        ref
            .watch(recommendationsProvider)
            .when(
              data: (items) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 270,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (_, i) => BookCard(
                  book: items[i],
                  onTap: () => context.push('/books/${items[i].id}'),
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => const EmptyState(
                title: 'No connection',
                message: 'Try again when you are online.',
              ),
            ),
      ],
    ),
  );
}
