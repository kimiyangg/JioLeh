import 'package:flutter/material.dart';

class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        SizedBox(height: 70),
        Text(
          "Sign in to explore your friends' favourite spots",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF7A736A),
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
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
          style: const TextStyle(
            color: Color(0xFF211D18),
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
