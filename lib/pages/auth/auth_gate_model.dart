import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:jio_leh/routing/auth_gate_resolver.dart';
import 'package:jio_leh/services/account_service.dart';
import 'package:jio_leh/services/auth_service.dart';

/// Which screen the AuthGate should show right now.
enum AuthGateScreen { loading, login, onboarding, map, error }

/// Works out which screen to show by checking the login state.
///
/// This is a plain class (not a widget) so it can be tested without any UI.
/// It tells listeners (the AuthGate widget) to redraw by calling
/// [notifyListeners] whenever the screen changes.
class AuthGateModel extends ChangeNotifier {
  AuthGateModel({required this.auth, required this.account});

  final AuthService auth;
  final AccountService account;

  AuthGateScreen _screen = AuthGateScreen.loading;
  AuthGateScreen get screen => _screen;

  StreamSubscription? _authChanges;

  /// Listen for login changes and do the first check.
  void start() {
    _authChanges = auth.authStateChanges().listen((_) => check());
    check();
  }

  /// Check the login state and update which screen to show.
  Future<void> check() async {
    _setScreen(AuthGateScreen.loading);
    try {
      final result = await resolveAuthGateState(
        isSignedIn: auth.isSignedIn,
        hasValidSession: auth.hasValidSession,
        profileExists: account.profileExists,
      );
      _setScreen(switch (result) {
        AuthGateResult.signedOut => AuthGateScreen.login,
        AuthGateResult.needsOnboarding => AuthGateScreen.onboarding,
        AuthGateResult.ready => AuthGateScreen.map,
      });
    } catch (_) {
      // Network / lookup errors show a retry screen instead of forcing login.
      _setScreen(AuthGateScreen.error);
    }
  }

  void _setScreen(AuthGateScreen next) {
    _screen = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _authChanges?.cancel();
    super.dispose();
  }
}
