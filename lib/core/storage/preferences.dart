import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);
final themeModeProvider = StateProvider<String>(
  (ref) =>
      ref.watch(sharedPreferencesProvider).getString('theme_mode') ?? 'system',
);
final languageProvider = StateProvider<String>(
  (ref) => ref.watch(sharedPreferencesProvider).getString('language') ?? 'en',
);
