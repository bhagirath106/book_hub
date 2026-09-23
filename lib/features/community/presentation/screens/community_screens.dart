import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../../core/widgets/bookhub_widgets.dart';

class CommunityHubScreen extends StatelessWidget {
  const CommunityHubScreen({super.key});
  @override
  Widget build(BuildContext context) => BookHubScaffold(
    title: 'Community',
    selectedIndex: 3,
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Read together',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text('Find people and places for your next conversation.'),
        const SizedBox(height: 24),
        ...['Fantasy Lovers', 'Silent Reading Club', 'Bookmarked & Bold'].map(
          (name) => Card(
            child: ListTile(
              onTap: () => context.push('/community/group'),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.groups),
              ),
              title: Text(name),
              subtitle: const Text(
                'Join readers discussing their current favorite books',
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ),
      ],
    ),
  );
}

class GroupDetailsScreen extends StatelessWidget {
  const GroupDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Fantasy Lovers')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(
          radius: 42,
          child: Icon(Icons.auto_stories, size: 36),
        ),
        const SizedBox(height: 16),
        Text(
          'Fantasy Lovers',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Text('12.4k readers · Public community'),
        const SizedBox(height: 24),
        FilledButton(onPressed: () {}, child: const Text('Join community')),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Recent discussions'),
        const ListTile(
          leading: Icon(Icons.forum_outlined),
          title: Text('What world would you visit?'),
          subtitle: Text('24 replies'),
        ),
      ],
    ),
  );
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) => const _ChatShell(title: 'Chat');
}

class VoiceChatScreen extends StatelessWidget {
  const VoiceChatScreen({super.key});
  @override
  Widget build(BuildContext context) => const _ChatShell(title: 'Voice room');
}

class StudyRoomScreen extends StatelessWidget {
  const StudyRoomScreen({super.key});
  @override
  Widget build(BuildContext context) => const _ChatShell(title: 'Study room');
}

class _ChatShell extends StatelessWidget {
  const _ChatShell({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Column(
      children: [
        const Expanded(
          child: EmptyState(
            title: 'Your room is quiet',
            message:
                'This prototype is ready for WebSocket and WebRTC services.',
            icon: Icons.forum,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(hintText: 'Write a message...'),
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
            ],
          ),
        ),
      ],
    ),
  );
}
