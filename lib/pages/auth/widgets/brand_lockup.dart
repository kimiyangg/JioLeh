import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

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
