import 'dart:async';

import 'package:flutter/material.dart';

import 'package:jio_leh/pages/auth/login_page.dart';
import 'package:jio_leh/pages/home/home_page.dart';
import 'package:jio_leh/pages/onboarding/onboarding_page.dart';

import 'package:jio_leh/pages/auth/gate/auth_gate_model.dart';
import 'package:jio_leh/pages/auth/gate/profile_link_holder.dart';

import 'package:jio_leh/routing/app_routing.dart';
import 'package:jio_leh/app/service_provider.dart';

import 'package:app_links/app_links.dart';

/// Decides which first screen the app should show based on login state.
///
/// This widget stays thin: the screen decision lives in [AuthGateModel] and the
/// deep-link logic lives in [ProfileLinkHolder]. The widget just listens to the
/// model, renders the matching screen, and does the actual navigation.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthGateModel _model;
  final _linkHolder = ProfileLinkHolder();

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    // Deep links need no services, so they can be set up here in initState.
    _appLinks = AppLinks();
    _linkSub = _appLinks.uriLinkStream.listen(_onLink);
  }

  // Services come from the ServiceProvider above us, which can't be read in
  // initState. Build the model here instead, once (the _didInit guard).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    // Get the nearest ServiceProvider from the widget tree.
    // The ! tells Dart that we expect it to exist here.
    // If no ServiceProvider is found above this widget, the app will crash.
    final services = ServiceProvider.of(context)!;
    _model = AuthGateModel(auth: services.auth, account: services.account)
      ..addListener(_onModelChange)
      ..start();
  }

  void _onModelChange() {
    setState(() {}); // redraw for the new screen
    if (_model.screen == AuthGateScreen.map) {
      // We just became ready — open a profile link if one was waiting.
      final id = _linkHolder.takeSavedLink();
      if (id != null) _openProfile(id);
    }
  }

  void _onLink(Uri uri) {
    final id = _linkHolder.handleLink(
      uri,
      isReady: _model.screen == AuthGateScreen.map,
    );
    if (id != null) _openProfile(id);
  }

  void _openProfile(String id) {
    // Navigate after the current frame, not during a build or state update.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(AppRoutes.profile(id));
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    _model.removeListener(_onModelChange);
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_model.screen == AuthGateScreen.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_model.screen == AuthGateScreen.login) {
      return const AuthPage();
    }

    if (_model.screen == AuthGateScreen.onboarding) {
      // onComplete re-checks so the gate moves on once the profile is made.
      return OnboardingPage(onComplete: _model.check);
    }

    if (_model.screen == AuthGateScreen.map) {
      return const HomePage();
    }

    // AuthGateScreen.error
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Something went wrong.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _model.check,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
