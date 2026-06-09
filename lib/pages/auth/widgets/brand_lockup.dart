import 'package:flutter/material.dart';

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
