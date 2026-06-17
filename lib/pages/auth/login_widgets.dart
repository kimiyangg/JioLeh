import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';

class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key});

  @override
  Widget build(BuildContext context) {
    final taglineSize = context.scaledFont(AppTextSizes.subtitle);

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
          style: TextStyle(
            color: AppColors.taglineText,
            fontSize: taglineSize,
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
    final headingSize = context.scaledFont(AppTextSizes.caption);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 25, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "Sign in to explore your friends' favourite spots",
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.authBodyText,
                fontSize: headingSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppPrimaryButton(
            label: 'Continue with Google',
            onPressed: onGooglePressed,
            leading: const _GoogleLogoDisc(),
            isLoading: isSigningIn,
            backgroundColor: AppColors.darkButton,
            liftColor: Colors.black,
          ),
          const SizedBox(height: 16),
          const _TermsText(),
        ],
      ),
    );
  }
}

class _TermsText extends StatefulWidget {
  const _TermsText();

  @override
  State<_TermsText> createState() => _TermsTextState();
}

class _TermsTextState extends State<_TermsText> {
  late final TapGestureRecognizer _privacyRecognizer = TapGestureRecognizer()
    ..onTap = () => launchUrl(
          Uri.parse('https://jio-leh-website.vercel.app/privacy'),
          mode: LaunchMode.inAppBrowserView,
        );

  @override
  void dispose() {
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termsSize = context.scaledFont(AppTextSizes.caption);

    return Text.rich(
      TextSpan(
        text: "By continuing you agree to our ",
        style: TextStyle(
          color: AppColors.authBodyText,
          fontSize: termsSize,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text: "Terms & Privacy",
            style: TextStyle(
              color: AppColors.authBodyText,
              fontSize: termsSize,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
            recognizer: _privacyRecognizer,
          ),
        ],
      ),
      textAlign: TextAlign.center,
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
