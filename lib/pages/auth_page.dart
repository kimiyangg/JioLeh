import 'package:flutter/material.dart';

import 'package:jio_leh/services/auth_services.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _auth = AuthServices();

  bool _isSigningIn = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningIn = true);

    try {
      await _auth.signInWithGoogle();
    } catch (error) {
      if (mounted) {
        _showSnackBar('Unexpected Error.');
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
      backgroundColor: const Color(0xFFE9E0CF),
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
                            child: _BrandLockup(),
                          ),
                        ),
                      ),
                      _SignInPanel(
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

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(height: 70),
        Text(
          "CURRENTLY LIVE ON BETA TESTING",
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: const Color(0xFFE9442E),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            height: 1,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 14),
        Text.rich(
          TextSpan(
            text: 'JioLeh',
            children: const [
              TextSpan(
                text: '!',
                style: TextStyle(color: Color(0xFFFF4A2E)),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            color: const Color(0xFF211D18),
            fontSize: 64,
            fontWeight: FontWeight.w900,
            height: 0.95,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Pin, drop, and jio - all on one map.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF776F65),
            fontSize: 17,
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _SignInPanel extends StatelessWidget {
  const _SignInPanel({
    required this.isSigningIn,
    required this.onGooglePressed,
  });

  final bool isSigningIn;
  final VoidCallback? onGooglePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Sign in to explore your friends' favourite spots",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7A736A),
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _GoogleSignInButton(
            isSigningIn: isSigningIn,
            onPressed: onGooglePressed,
          ),
        ],
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.isSigningIn,
    required this.onPressed,
  });

  final bool isSigningIn;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 54,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF211D18),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF4B443B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          child: 
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _GoogleLogoDisc(),
                SizedBox(width: 11),
                Text('Continue with Google'),
              ],
            ),
        ),
      ),
    );
  }
}

class _GoogleLogoDisc extends StatelessWidget {
  const _GoogleLogoDisc();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Image(
        image: AssetImage('assets/google_logo.png'),
        width: 14,
        height: 14,
      ),
    );
  }
}
