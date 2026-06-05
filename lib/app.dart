import 'dart:async';

import 'package:flutter/material.dart';

import 'package:jio_leh/pages/auth/login_page.dart';
import 'package:jio_leh/pages/map/map_page.dart';
import 'package:jio_leh/pages/auth/onboarding_page.dart';

import 'package:jio_leh/services/services.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}

enum _GateState { loading, signedOut, needsOnboarding, ready, error }

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _auth = Services.auth;
  late final _account = Services.account;
  late final StreamSubscription<dynamic> _authSub;
  _GateState _state = _GateState.loading;

  @override
  void initState() {
    super.initState();
    // Re-resolve whenever the user signs in or out, then resolve once now
    // for the current session.
    _authSub = _auth.authStateChanges().listen((_) => _resolve());
    _resolve();
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  Future<void> _resolve() async {
    if (!_auth.isSignedIn()) {
      setState(() => _state = _GateState.signedOut);
      return;
    }

    setState(() => _state = _GateState.loading);
    try {
      final exists = await _account.profileExists();
      if (!mounted) return; // widget may be disposed during the await
      setState(() =>
          _state = exists ? _GateState.ready : _GateState.needsOnboarding);
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _GateState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _GateState.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case _GateState.signedOut:
        return const AuthPage();
      case _GateState.needsOnboarding:
        // onComplete re-runs the check so the gate moves to MapPage once the
        // profile row has been inserted.
        return OnboardingPage(onComplete: _resolve);
      case _GateState.ready:
        return const MapPage();
      case _GateState.error:
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Something went wrong.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _resolve,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
    }
  }
}
