import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_hub/main.dart';
import 'package:book_hub/core/storage/preferences.dart';

void main() {
  testWidgets('BookHub home renders its discovery experience when logged in', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'auth_is_logged_in': true,
      'auth_username': 'Amara',
    });
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const BookHubApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text("Amara's library"), findsAtLeastNWidgets(1));
    expect(find.text('Good evening,'), findsOneWidget);
    expect(find.text('Ask AI'), findsOneWidget);
  });

  testWidgets('BookHub redirects to login when not logged in', (tester) async {
    SharedPreferences.setMockInitialValues({'auth_is_logged_in': false});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const BookHubApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
