import 'package:flutter/material.dart';

class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key});

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