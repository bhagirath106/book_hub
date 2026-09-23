import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_hub/main.dart';

void main() {
  testWidgets('BookHub home renders its discovery experience', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BookHubApp()));
    expect(find.text('BookHub'), findsOneWidget);
    expect(find.text('Your reading world'), findsOneWidget);
    expect(find.text('Ask AI'), findsOneWidget);
  });
}
