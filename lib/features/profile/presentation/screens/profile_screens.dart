import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/preferences.dart';
import '../../../home/presentation/screens/home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => BookHubScaffold(
    selectedIndex: 4,
    title: 'Profile',
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(radius: 44, child: Icon(Icons.person, size: 42)),
        const SizedBox(height: 14),
        Text(
          'Reader',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Text(
          'Building a world one page at a time.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 26),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings'),
              ),
              ListTile(
                leading: const Icon(Icons.insights_outlined),
                title: const Text('Reading analytics'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/analytics'),
              ),
              ListTile(
                leading: const Icon(Icons.monetization_on_outlined),
                title: const Text('Rewards & coins'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/rewards'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(
      children: [
        ListTile(
          title: const Text('Theme'),
          subtitle: const Text('System, light, dark, AMOLED'),
          leading: const Icon(Icons.palette_outlined),
          onTap: () => context.push('/settings/theme'),
        ),
        ListTile(
          title: const Text('Language'),
          subtitle: const Text('English / Hindi'),
          leading: const Icon(Icons.translate),
          onTap: () => context.push('/settings/language'),
        ),
        const ListTile(
          title: Text('Offline-first storage'),
          subtitle: Text(
            'Your preferences and reading progress stay on this device',
          ),
          leading: Icon(Icons.cloud_done_outlined),
        ),
      ],
    ),
  );
}

class ThemeSelectionScreen extends ConsumerWidget {
  const ThemeSelectionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => _ChoiceScreen(
    title: 'Theme',
    values: const ['system', 'light', 'dark', 'amoled'],
    selected: ref.watch(themeModeProvider),
    onSelected: (value) async {
      ref.read(themeModeProvider.notifier).state = value;
      await ref.read(sharedPreferencesProvider).setString('theme_mode', value);
    },
  );
}

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => _ChoiceScreen(
    title: 'Language',
    values: const ['en', 'hi'],
    selected: ref.watch(languageProvider),
    onSelected: (value) async {
      ref.read(languageProvider.notifier).state = value;
      await ref.read(sharedPreferencesProvider).setString('language', value);
    },
  );
}

class _ChoiceScreen extends StatelessWidget {
  const _ChoiceScreen({
    required this.title,
    required this.values,
    required this.selected,
    required this.onSelected,
  });
  final String title;
  final List<String> values;
  final String selected;
  final Future<void> Function(String) onSelected;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Column(
      children: values
          .map(
            // ignore: deprecated_member_use
            (value) => RadioListTile<String>(
              value: value,
              // ignore: deprecated_member_use
              groupValue: selected,
              title: Text(
                value == 'en'
                    ? 'English'
                    : value == 'hi'
                    ? 'Hindi'
                    : value[0].toUpperCase() + value.substring(1),
              ),
              // ignore: deprecated_member_use
              onChanged: (next) {
                if (next != null) onSelected(next);
              },
            ),
          )
          .toList(),
    ),
  );
}
