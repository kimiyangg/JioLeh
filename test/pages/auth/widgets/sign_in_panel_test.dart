import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/pages/auth/widgets/sign_in_panel.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';

void main() {
  Widget buildPanel({
    bool isGoogleSigningIn = false,
    bool isAppleSigningIn = false,
    VoidCallback? onApplePressed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SignInPanel(
          isGoogleSigningIn: isGoogleSigningIn,
          isAppleSigningIn: isAppleSigningIn,
          onGooglePressed: () {},
          onApplePressed: onApplePressed,
        ),
      ),
    );
  }

  Finder appleButton() =>
      find.widgetWithText(AppPrimaryButton, 'Continue with Apple');

  testWidgets(
    'hides the Apple button and keeps the full-width Google label when onApplePressed is null',
    (tester) async {
      await tester.pumpWidget(buildPanel());

      expect(appleButton(), findsNothing);
      expect(
        find.widgetWithText(AppPrimaryButton, 'Continue with Apple'),
        findsNothing,
      );
      expect(
        find.widgetWithText(AppPrimaryButton, 'Continue with Google'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows the full-width Apple button when onApplePressed is provided',
    (tester) async {
      await tester.pumpWidget(buildPanel(onApplePressed: () {}));

      expect(appleButton(), findsOneWidget);
      expect(
        find.widgetWithText(AppPrimaryButton, 'Continue with Google'),
        findsOneWidget,
      );
    },
  );

  testWidgets('with both callbacks Apple is stacked above Google', (
    tester,
  ) async {
    await tester.pumpWidget(buildPanel(onApplePressed: () {}));

    final googleTop = tester.getTopLeft(
      find.widgetWithText(AppPrimaryButton, 'Continue with Google'),
    );
    final appleTop = tester.getTopLeft(appleButton());
    expect(googleTop.dx, appleTop.dx);
    expect(appleTop.dy, lessThan(googleTop.dy));
  });

  testWidgets('tapping the Apple button fires onApplePressed', (tester) async {
    var calls = 0;
    await tester.pumpWidget(buildPanel(onApplePressed: () => calls++));

    await tester.tap(appleButton());
    await tester.pump();

    expect(calls, 1);
  });

  testWidgets(
    'while signing in, the Apple button shows a spinner and ignores taps',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        buildPanel(isAppleSigningIn: true, onApplePressed: () => calls++),
      );

      // The label is replaced by the loading spinner, so find the Apple button by position.
      final appleLoadingButton = find.byType(AppPrimaryButton).first;
      expect(
        find.descendant(
          of: appleLoadingButton,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );

      await tester.tap(appleLoadingButton, warnIfMissed: false);
      await tester.pump();

      expect(calls, 0);
    },
  );
}
