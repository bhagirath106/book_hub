import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_hub/main.dart';
import 'package:book_hub/core/storage/preferences.dart';

void main() {
  testWidgets('BookHub home renders its discovery experience', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const BookHubApp(),
      ),
    );
    expect(find.text('BookHub'), findsOneWidget);
    expect(find.text('Your reading world'), findsOneWidget);
    expect(find.text('Ask AI'), findsOneWidget);
  });
}
