import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:book_hub/core/widgets/bookhub_widgets.dart';

void main() {
  testWidgets('empty state matches the BookHub visual baseline', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            title: 'Nothing here yet',
            message: 'Your saved books will appear here.',
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(EmptyState),
      matchesGoldenFile('goldens/empty_state.png'),
    );
  });
}
