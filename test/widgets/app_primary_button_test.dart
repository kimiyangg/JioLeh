import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/widgets/app_primary_button.dart';

void main() {
  // Every widget needs a MaterialApp ancestor for theme and Directionality.
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('AppPrimaryButton', () {
    testWidgets('shows its label', (tester) async {
      await tester.pumpWidget(wrap(
        AppPrimaryButton(label: 'Continue', onPressed: () {}),
      ));

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('tapping calls onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(wrap(
        AppPrimaryButton(label: 'Continue', onPressed: () => taps++),
      ));

      await tester.tap(find.byType(AppPrimaryButton));

      expect(taps, 1);
    });

    testWidgets('while loading: shows a spinner and hides the label', (tester) async {
      await tester.pumpWidget(wrap(
        AppPrimaryButton(label: 'Continue', isLoading: true, onPressed: () {}),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('while loading: taps are blocked', (tester) async {
      var taps = 0;
      await tester.pumpWidget(wrap(
        AppPrimaryButton(label: 'Continue', isLoading: true, onPressed: () => taps++),
      ));

      await tester.tap(find.byType(AppPrimaryButton));

      expect(taps, 0);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(wrap(
        const AppPrimaryButton(label: 'Continue', onPressed: null),
      ));

      // A FilledButton with a null callback reports itself as disabled.
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.enabled, isFalse);
    });
  });
}
