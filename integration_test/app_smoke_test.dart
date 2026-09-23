import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_hub/app/app.dart';
import 'package:book_hub/core/storage/preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BookHub launches into the application shell', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const BookHubApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Good evening,'), findsOneWidget);
    expect(find.text('Ask AI'), findsOneWidget);
  });
}
