import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/widgets/app_secondary_button.dart';

void main() {
  // Every widget needs a MaterialApp ancestor for theme and Directionality.
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('AppSecondaryButton', () {
    testWidgets('shows its label', (tester) async {
      await tester.pumpWidget(wrap(
        AppSecondaryButton(label: 'Continue', onPressed: () {}),
      ));

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('tapping calls onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(wrap(
        AppSecondaryButton(label: 'Continue', onPressed: () => taps++),
      ));

      await tester.tap(find.byType(AppSecondaryButton));

      expect(taps, 1);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(wrap(
        const AppSecondaryButton(label: 'Continue', onPressed: null),
      ));

      // A FilledButton with a null callback reports itself as disabled.
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.enabled, isFalse);
    });

    testWidgets('icon can be rendered successfully', (tester) async {
      await tester.pumpWidget(wrap(
        const AppSecondaryButton(label: 'Continue', onPressed: null, icon: Icons.share,)
      ));

      // findWidgets: one or more
      // findNothing: none
      // findsOneWidger: exactly one widget
      expect(find.byIcon(Icons.share), findsOne);
    });
  });
}
