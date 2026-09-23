import 'package:flutter/material.dart';
import '../../app/theme/bookhub_theme.dart';
import '../../features/books/domain/book.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.action, super.key});
  final String title;
  final VoidCallback? action;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      if (action != null)
        TextButton(onPressed: action, child: const Text('See all')),
    ],
  );
}

class BookCard extends StatelessWidget {
  const BookCard({required this.book, this.onTap, super.key});
  final Book book;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: SizedBox(
      width: 142,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'book-${book.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 190,
                width: 142,
                child: book.coverUrl == null
                    ? Container(
                        color: BookHubColors.violet.withValues(alpha: .16),
                        child: const Icon(Icons.menu_book, size: 44),
                      )
                    : Image.network(
                        book.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const _CoverFallback(),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();
  @override
  Widget build(BuildContext context) => Container(
    color: BookHubColors.violet.withValues(alpha: .16),
    child: const Icon(Icons.menu_book, size: 44),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.auto_stories,
    super.key,
  });
  final String title;
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: BookHubColors.violet),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}

class AIButton extends StatefulWidget {
  const AIButton({this.onPressed, super.key});
  final VoidCallback? onPressed;
  @override
  State<AIButton> createState() => _AIButtonState();
}

class _AIButtonState extends State<AIButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: Tween(
      begin: .96,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
    child: FloatingActionButton.extended(
      onPressed: widget.onPressed,
      backgroundColor: BookHubColors.violet,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.auto_awesome),
      label: const Text('Ask AI'),
    ),
  );
}
