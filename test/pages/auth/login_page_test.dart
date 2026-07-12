import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/pages/auth/login_page.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';

import '../../services/fakes/fake_auth_service.dart';

void main() {
  final onIos = TargetPlatformVariant.only(TargetPlatform.iOS);
  final onAndroid = TargetPlatformVariant.only(TargetPlatform.android);

  void usePhoneSizedScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
  }

  Widget buildPage(FakeAuthService auth) {
    return MaterialApp(
      home: ServiceProvider(
        auth: auth,
        child: const AuthPage(),
      ),
    );
  }

  Finder appleButton() => find.widgetWithText(AppPrimaryButton, 'Continue with Apple');

  testWidgets('shows the Apple button when the platform is iOS', (tester) async {
    usePhoneSizedScreen(tester);
    await tester.pumpWidget(buildPage(FakeAuthService()));

    expect(appleButton(), findsOneWidget);
  }, variant: onIos);

  testWidgets('hides the Apple button when the platform is Android', (tester) async {
    usePhoneSizedScreen(tester);
    await tester.pumpWidget(buildPage(FakeAuthService()));

    expect(appleButton(), findsNothing);
  }, variant: onAndroid);

  testWidgets('tapping the Apple button calls signInWithApple exactly once', (tester) async {
    usePhoneSizedScreen(tester);
    final auth = FakeAuthService();
    await tester.pumpWidget(buildPage(auth));

    await tester.tap(appleButton());
    await tester.pump();

    expect(auth.appleSignInCalls, 1);
    expect(auth.signInCalls, 0);
  }, variant: onIos);

  testWidgets('a cancelled Apple sign-in shows no error snackbar', (tester) async {
    usePhoneSizedScreen(tester);
    final auth = FakeAuthService()
      ..appleSignInError = const SignInCancelledException();
    await tester.pumpWidget(buildPage(auth));

    await tester.tap(appleButton());
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
  }, variant: onIos);

  testWidgets('a failed Apple sign-in shows the error snackbar', (tester) async {
    usePhoneSizedScreen(tester);
    final auth = FakeAuthService()..appleSignInError = Exception('network down');
    await tester.pumpWidget(buildPage(auth));

    await tester.tap(appleButton());
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
  }, variant: onIos);
}
