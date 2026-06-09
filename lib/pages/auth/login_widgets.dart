import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        SizedBox(height: 100),
        SizedBox(
          height: 150,
          width: 450,
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Pin, drop, and jio - all on one map.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF776F65),
            fontSize: 17,
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class SignInPanel extends StatelessWidget {
  const SignInPanel({
    super.key,
    required this.isSigningIn,
    required this.onGooglePressed,
  });

  final bool isSigningIn;
  final VoidCallback? onGooglePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 25, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
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
            style: const TextStyle(
              color: Color(0xFF7A736A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _GoogleSignInButton(
            isSigningIn: isSigningIn,
            onPressed: onGooglePressed,
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              text: "By continuing you agree to our ",
              style: const TextStyle(
                color: Color(0xFF7A736A),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: "Terms & Privacy",
                  style: const TextStyle(
                    color: Color(0xFF7A736A),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => launchUrl(
                      Uri.parse('https://jio-leh-website.vercel.app/privacy'),
                      mode: LaunchMode.inAppBrowserView,
                    ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
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
