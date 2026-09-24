import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'theme/bookhub_theme.dart';
import '../core/storage/preferences.dart';

class BookHubApp extends ConsumerWidget {
  const BookHubApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'BookHub',
      debugShowCheckedModeBanner: false,
      theme: mode == 'amoled' ? BookHubTheme.amoled() : BookHubTheme.light(),
      darkTheme: BookHubTheme.dark(),
      themeMode: mode == 'dark' || mode == 'amoled'
          ? ThemeMode.dark
          : mode == 'light'
          ? ThemeMode.light
          : ThemeMode.system,
      routerConfig: router,
    );
  }
}
