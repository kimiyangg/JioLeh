import 'dart:async';

import 'package:flutter/material.dart';

import 'package:jio_leh/pages/auth/login_page.dart';
import 'package:jio_leh/pages/map/map_page.dart';
import 'package:jio_leh/pages/auth/onboarding_page.dart';

import 'package:jio_leh/services/auth_gate_resolver.dart';
import 'package:jio_leh/services/services.dart';

import 'package:app_links/app_links.dart';
import 'package:jio_leh/pages/profile_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
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
  late final AppLinks _appLinks;
  late final StreamSubscription<Uri> _linkSub;
  String? _pendingProfileId;

  void _handleLink(Uri uri) {
    final validLink =
        uri.scheme == 'com.gijios.jioleh' &&
        uri.host == 'profile' &&
        uri.pathSegments.length == 1;

    if (!validLink) return;

    _pendingProfileId = uri.pathSegments.first;
    _openPendingProfile();
  }

  

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _linkSub = _appLinks.uriLinkStream.listen(_handleLink);
    // Re-resolve whenever the user signs in or out, then resolve once now
    // for the current session.
    _authSub = _auth.authStateChanges().listen((_) => _resolve());
    _resolve();
  }

  @override
  void dispose() {
    _authSub.cancel();
    _linkSub.cancel();
    super.dispose();
  }

  Future<void> _resolve() async {
    if (!_auth.isSignedIn()) {
      setState(() => _state = _GateState.signedOut);
      return;
    }

    setState(() => _state = _GateState.loading);
    // Check if the user session is valid and if a profile exists.
    try {
      final result = await resolveAuthGateState(
        isSignedIn: _auth.isSignedIn,
        hasValidSession: _auth.hasValidSession,
        profileExists: _account.profileExists,
      );
      if (!mounted) return; // widget may be disposed during the await
      if (result == AuthGateResult.signedOut) {
        setState(() => _state = _GateState.signedOut);
      } else if (result == AuthGateResult.needsOnboarding) {
        setState(() => _state = _GateState.needsOnboarding);
      } else {
        setState(() => _state = _GateState.ready);
        _openPendingProfile();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _GateState.error);
    }
  }

  void _openPendingProfile() {
    final profileId = _pendingProfileId;

    if (_state != _GateState.ready || profileId == null) return;

    _pendingProfileId = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ProfilePage(userId: profileId),
        ),
      );
    });
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
