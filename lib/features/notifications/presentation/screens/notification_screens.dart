import 'package:flutter/material.dart';
import '../../../../core/widgets/bookhub_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Notifications'),
      actions: [TextButton(onPressed: () {}, child: const Text('Read all'))],
    ),
    body: ListView(
      padding: const EdgeInsets.all(12),
      children: const [
        ListTile(
          leading: CircleAvatar(child: Icon(Icons.local_fire_department)),
          title: Text('Your reading streak is 7 days!'),
          subtitle: Text('Keep going · Today'),
        ),
        ListTile(
          leading: CircleAvatar(child: Icon(Icons.groups)),
          title: Text('Fantasy Lovers has a new discussion'),
          subtitle: Text('Yesterday'),
        ),
        SizedBox(
          height: 120,
          child: EmptyState(
            title: 'You are all caught up',
            message:
                'New reading, community, and reward updates will appear here.',
            icon: Icons.notifications_none,
          ),
        ),
      ],
    ),
  );
}
