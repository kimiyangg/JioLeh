import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:jio_leh/pages/auth/auth_gate_model.dart';
import 'package:jio_leh/services/account_service.dart';

import '../../services/fakes/fake_auth_service.dart';

// AccountService isn't an interface, but mocktail can still fake it so we can
// control what profileExists() returns.
class _MockAccountService extends Mock implements AccountService {}

void main() {
  late _MockAccountService account;

  setUp(() {
    account = _MockAccountService();
  });

  test('starts on the loading screen', () {
    final model = AuthGateModel(
      auth: FakeAuthService(signedIn: false),
      account: account,
    );

    expect(model.screen, AuthGateScreen.loading);
  });

  test('not signed in -> login screen', () async {
    final model = AuthGateModel(
      auth: FakeAuthService(signedIn: false),
      account: account,
    );

    await model.check();

    expect(model.screen, AuthGateScreen.login);
  });

  test('signed in but session invalid -> login screen', () async {
    final model = AuthGateModel(
      auth: FakeAuthService(signedIn: true, validSession: false),
      account: account,
    );

    await model.check();

    expect(model.screen, AuthGateScreen.login);
  });

  test('signed in, valid session, no profile -> onboarding screen', () async {
    when(() => account.profileExists()).thenAnswer((_) async => false);
    final model = AuthGateModel(
      auth: FakeAuthService(signedIn: true, validSession: true),
      account: account,
    );

    await model.check();

    expect(model.screen, AuthGateScreen.onboarding);
  });

  test('signed in, valid session, has profile -> map screen', () async {
    when(() => account.profileExists()).thenAnswer((_) async => true);
    final model = AuthGateModel(
      auth: FakeAuthService(signedIn: true, validSession: true),
      account: account,
    );

    await model.check();

    expect(model.screen, AuthGateScreen.map);
  });

  test('profile lookup failure -> error screen', () async {
    when(() => account.profileExists()).thenThrow(Exception('network down'));
    final model = AuthGateModel(
      auth: FakeAuthService(signedIn: true, validSession: true),
      account: account,
    );

    await model.check();

    expect(model.screen, AuthGateScreen.error);
  });
}
