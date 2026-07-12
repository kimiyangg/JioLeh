import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/services/auth_service.dart';

import 'widgets/brand_lockup.dart';
import 'widgets/sign_in_panel.dart';

import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_snack_bar.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isSigningIn = false;

  Future<void> _signInWithGoogle() async {
    // Read the service from the provider before the first await (context is
    // valid here because this runs after the widget is built).
    final auth = ServiceProvider.of(context)!.auth;

    setState(() => _isSigningIn = true);

    try {
      await auth.signInWithGoogle();
    } catch (error, stackTrace) {
      // Log the real cause so failures are diagnosable, then show the user an
      // honest, actionable message instead of a generic "unexpected" one.
      debugPrint('Google sign-in failed: $error\n$stackTrace');
      if (mounted) {
        context.showAppSnackBar(
          'Could not start sign-in. Check your connection and try again.',
          kind: SnackBarKind.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  Future<void> _signInWithApple() async {
    final auth = ServiceProvider.of(context)!.auth;

    setState(() => _isSigningIn = true);

    try {
      await auth.signInWithApple();
    } on SignInCancelledException {
      // The user backed out of the Apple sheet themselves; not an error.
    } catch (error, stackTrace) {
      debugPrint('Apple sign-in failed: $error\n$stackTrace');
      if (mounted) {
        context.showAppSnackBar(
          'Could not sign in with Apple. Please try again.',
          kind: SnackBarKind.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(36, 20, 36, 34),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            child: BrandLockup(),
                          ),
                        ),
                      ),
                      SignInPanel(
                        isSigningIn: _isSigningIn,
                        onGooglePressed:
                            _isSigningIn ? null : _signInWithGoogle,
                        onApplePressed:
                            defaultTargetPlatform == TargetPlatform.iOS
                                ? _signInWithApple
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


