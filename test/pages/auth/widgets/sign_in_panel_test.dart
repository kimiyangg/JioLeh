import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/pages/auth/widgets/sign_in_panel.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';

void main() {
  Widget buildPanel({
    bool isSigningIn = false,
    VoidCallback? onApplePressed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SignInPanel(
          isSigningIn: isSigningIn,
          onGooglePressed: () {},
          onApplePressed: onApplePressed,
        ),
      ),
    );
  }

  Finder appleButton() => find.widgetWithText(AppPrimaryButton, 'Continue with Apple');

  testWidgets('hides the Apple button when onApplePressed is null', (tester) async {
    await tester.pumpWidget(buildPanel());

    expect(appleButton(), findsNothing);
  });

  testWidgets('shows the Apple button when onApplePressed is provided', (tester) async {
    await tester.pumpWidget(buildPanel(onApplePressed: () {}));

    expect(appleButton(), findsOneWidget);
  });

  testWidgets('tapping the Apple button fires onApplePressed', (tester) async {
    var calls = 0;
    await tester.pumpWidget(buildPanel(onApplePressed: () => calls++));

    await tester.tap(appleButton());
    await tester.pump();

    expect(calls, 1);
  });

  testWidgets('while signing in, the Apple button shows a spinner and ignores taps', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      buildPanel(isSigningIn: true, onApplePressed: () => calls++),
    );

    // The label is replaced by the loading spinner, so find the button by position (Google first, Apple second).
    final appleLoadingButton = find.byType(AppPrimaryButton).at(1);
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
  });
}
