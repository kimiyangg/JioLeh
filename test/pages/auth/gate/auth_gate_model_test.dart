import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/pages/auth/gate/auth_gate_model.dart';

import '../../../services/fakes/fake_account_service.dart';
import '../../../services/fakes/fake_auth_service.dart';

void main() {
  test('starts on the loading screen', () {
    final model = AuthGateModel(
      auth: FakeAuthService(signedIn: false),
      account: FakeAccountService(),
    );

    expect(model.screen, AuthGateScreen.loading);
  });

  test('not signed in -> login screen', () async {
    final model = AuthGateModel(
      auth: FakeAuthService(signedIn: false),
      account: FakeAccountService(),
    );

    await model.check();

    expect(model.screen, AuthGateScreen.login);
  });

  test('signed in but session invalid -> login screen', () async {
    final model = AuthGateModel(
      auth: FakeAuthService(signedIn: true, validSession: false),
      account: FakeAccountService(),
    );

    await model.check();

    expect(model.screen, AuthGateScreen.login);
  });

  test('signed in, valid session, no profile -> onboarding screen', () async {
    final model = AuthGateModel(
      auth: FakeAuthService(signedIn: true, validSession: true),
      account: FakeAccountService(hasProfile: false),
    );

    await model.check();

    expect(model.screen, AuthGateScreen.onboarding);
  });

  test('signed in, valid session, has profile -> map screen', () async {
    final model = AuthGateModel(
      auth: FakeAuthService(signedIn: true, validSession: true),
      account: FakeAccountService(hasProfile: true),
    );

    await model.check();

    expect(model.screen, AuthGateScreen.map);
  });

  test('profile lookup failure -> error screen', () async {
    final account = FakeAccountService()
      ..profileExistsHandler = () => Future.error(Exception('network down'));
    final model = AuthGateModel(
      auth: FakeAuthService(signedIn: true, validSession: true),
      account: account,
    );

    await model.check();

    expect(model.screen, AuthGateScreen.error);
  });

  test('a stale check cannot overwrite a newer one', () async {
    // Hand out a fresh Completer each time profileExists() is called, so the
    // test controls exactly when each check() finishes.
    final completers = <Completer<bool>>[];
    final account = FakeAccountService()
      ..profileExistsHandler = () {
        final completer = Completer<bool>();
        completers.add(completer);
        return completer.future;
      };

    final model = AuthGateModel(
      auth: FakeAuthService(signedIn: true, validSession: true),
      account: account,
    );

    // Start two checks and let both run up to the profileExists() await.
    final older = model.check();
    final newer = model.check();
    await pumpEventQueue();
    expect(completers.length, 2);

    // Finish the NEWER check first -> map.
    completers[1].complete(true);
    await pumpEventQueue();
    expect(model.screen, AuthGateScreen.map);

    // Finish the OLDER check second with a different answer. It is stale, so it
    // must be dropped and the screen must stay map.
    completers[0].complete(false); // would be onboarding if not dropped
    await pumpEventQueue();
    expect(model.screen, AuthGateScreen.map);

    await older;
    await newer;
  });
}
