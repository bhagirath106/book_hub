import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/book_repository.dart';
import 'providers.dart';

void main() => runApp(const ProviderScope(child: BookHubApp()));

class BookHubApp extends StatelessWidget {
  const BookHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6655d9)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xfff8f7fc),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(bookSearchProvider(_query));
    return Scaffold(
      appBar: AppBar(
        title: const Text('BookHub', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Ask AI'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          Text('Your reading world', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Discover your next great story.', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onSubmitted: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              hintText: 'Search books, authors, genres',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          Text(_query.isEmpty ? 'Continue exploring' : 'Search results', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          books.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (error, _) => _EmptyState(message: 'Connect BookHub to discover books.'),
            data: (items) => items.isEmpty
                ? const _EmptyState(message: 'No books found yet.')
                : Column(children: items.map((book) => _BookTile(book: book)).toList()),
          ),
        ],
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book});
  final Book book;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: book.coverUrl == null
                ? Container(width: 52, height: 72, color: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Icons.menu_book))
                : Image.network(book.coverUrl!, width: 52, height: 72, fit: BoxFit.cover),
          ),
          title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(book.author.isEmpty ? 'BookHub discovery' : book.author),
          trailing: const Icon(Icons.chevron_right),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(message, textAlign: TextAlign.center)));
}
