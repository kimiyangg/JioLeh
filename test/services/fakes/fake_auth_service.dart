import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/services/auth_service.dart';

/// A pretend AuthService for tests. No internet — everything is in memory and
/// you control it from the test.
class FakeAuthService extends AuthService {
  FakeAuthService({
    User? user,
    bool signedIn = false,
    bool validSession = true,
  })  : _user = user,
        _signedIn = signedIn,
        _validSession = validSession;

  // Set these from a test to pretend different login states.
  final User? _user;
  bool _signedIn;
  final bool _validSession;

  // A fake "login changed" channel the test can push events into.
  final _controller = StreamController<AuthState>.broadcast();

  // Counters so tests can check "did sign in / sign out get called?".
  int signInCalls = 0;
  int appleSignInCalls = 0;
  int signOutCalls = 0;

  // Set from a test to make the next Apple sign-in attempt throw.
  Object? appleSignInError;

  @override
  User? getCurrentUser() => _user;

  @override
  bool isSignedIn() => _signedIn;

  @override
  Future<bool> hasValidSession() async => _signedIn && _validSession;

  @override
  Stream<AuthState> authStateChanges() => _controller.stream;

  @override
  Future<void> signInWithGoogle() async => signInCalls++;

  @override
  Future<void> signInWithApple() async {
    appleSignInCalls++;
    if (appleSignInError != null) throw appleSignInError!;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    _signedIn = false;
  }
}
