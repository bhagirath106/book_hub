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
      title: "Amara's library",
      selectedIndex: 0,
      floatingActionButton: AIButton(onPressed: () => context.push('/ai')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        children: [
          Text('Good evening,', style: Theme.of(context).textTheme.bodyLarge),
          Text(
            "Amara's library",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Read. Listen. Belong.',
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
          Row(
            children: const [
              _StatCard(
                icon: Icons.local_fire_department,
                value: '12 days',
                label: 'streak',
              ),
              SizedBox(width: 10),
              _StatCard(icon: Icons.schedule, value: '48 min', label: 'today'),
              SizedBox(width: 10),
              _StatCard(
                icon: Icons.check_box_outlined,
                value: '23',
                label: 'finished',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: BookHubColors.gold,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffd49124),
                child: Icon(Icons.monetization_on, color: Colors.black),
              ),
              title: const Text(
                '1,240 coins',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                '5 pages left in this chapter · 2/3 ads watched',
                style: TextStyle(color: Colors.black87),
              ),
              trailing: FilledButton(
                onPressed: () => context.push('/rewards'),
                child: const Text('Earn'),
              ),
            ),
          ),
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
                  heroTag: 'recommended-${items[index].id}',
                  onTap: () => context.push('/books/${items[index].id}'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          SectionHeader(
            title: 'Trending now',
            action: () => context.push('/discover'),
          ),
          const SizedBox(height: 12),
          books.when(
            loading: () => const SizedBox(
              height: 190,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const EmptyState(
              title: 'Offline mode',
              message: 'Saved books are still available.',
            ),
            data: (items) => SizedBox(
              height: 270,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (_, index) => BookCard(
                  book: items[index],
                  heroTag: 'recommended-${items[index].id}',
                  onTap: () => context.push('/books/${items[index].id}'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          SectionHeader(
            title: 'Popular audiobooks',
            action: () => context.push('/audiobooks'),
          ),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: BookHubColors.terracotta,
                child: Icon(Icons.headphones, color: Colors.black),
              ),
              title: const Text('Project Hail Mary'),
              subtitle: const Text('Andy Weir · 13h 46m'),
              trailing: IconButton(
                onPressed: () => context.push('/audiobook/player'),
                icon: const Icon(
                  Icons.play_circle,
                  color: BookHubColors.gold,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          SectionHeader(
            title: 'Community buzz',
            action: () => context.push('/community'),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.groups),
              title: const Text('Fantasy Lovers · 12.4k'),
              subtitle: const Text(
                'Is “The Salt Road” ending divisive? · 128 replies',
              ),
              onTap: () => context.push('/community'),
            ),
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
    color: Theme.of(context).cardColor,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 104,
              decoration: BoxDecoration(
                color: BookHubColors.gold,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: const Text(
                'The\nSalt\nRoad',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue reading',
                    style: TextStyle(color: BookHubColors.sage),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'The Salt Road',
                    style: TextStyle(
                      color: BookHubColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: .62,
                    color: BookHubColors.gold,
                    backgroundColor: BookHubColors.muted,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(onPressed: onTap, child: const Text('Resume')),
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
                  heroTag: 'discover-${items[i].id}',
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
