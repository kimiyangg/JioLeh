import 'package:flutter/material.dart';

import 'package:jio_leh/app/service_provider.dart';

import 'login_widgets.dart';

import 'package:jio_leh/theme.dart';

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
        _showSnackBar('Could not start sign-in. Check your connection and try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: .circular(10.0)),
    ));
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


