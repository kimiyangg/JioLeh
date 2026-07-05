import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:jio_leh/pages/auth/gate/auth_gate_resolver.dart';
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

  // Each check() takes the next ticket number. Only the call holding the
  // latest ticket may write its result, so a slower older check can't overwrite
  // a newer one. _disposed stops us notifying after the model is thrown away.
  int _latestCheck = 0;
  bool _disposed = false;

  /// Listen for login changes and do the first check.
  void start() {
    _authChanges = auth.authStateChanges().listen((_) => check());
    check();
  }

  /// Check the login state and update which screen to show.
  Future<void> check() async {
    final myCheck = ++_latestCheck; // claim the newest ticket
    // Only force loading when recovering from an error retry.
    if (screen == AuthGateScreen.error) _setScreen(AuthGateScreen.loading);
    try {
      final result = await resolveAuthGateState(
        isSignedIn: auth.isSignedIn,
        hasValidSession: auth.hasValidSession,
        profileExists: account.profileExists,
      );
      // A newer check started, or check disposed, then drop stale result.
      if (_disposed || myCheck != _latestCheck) return;
      _setScreen(switch (result) {
        AuthGateResult.signedOut => AuthGateScreen.login,
        AuthGateResult.needsOnboarding => AuthGateScreen.onboarding,
        AuthGateResult.ready => AuthGateScreen.map,
      });
    } catch (error, stackTrace) {
      // Log the real cause so failures are diagnosable instead of swallowed.
      debugPrint('AuthGate check failed: $error\n$stackTrace');
      // No need to switch the screen to error if this is not the latest ticket.
      if (_disposed || myCheck != _latestCheck) return;
      // Errors show a retry screen instead of forcing login.
      _setScreen(AuthGateScreen.error);
    }
  }

  void _setScreen(AuthGateScreen next) {
    _screen = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _authChanges?.cancel();
    super.dispose();
  }
}
