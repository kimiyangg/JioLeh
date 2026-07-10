import 'package:flutter/material.dart';
import 'package:jio_leh/theme.dart';

class AppSectionHeading extends StatelessWidget {
  const AppSectionHeading({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textSize = context.scaledFont(AppTextSizes.body);

    return Text(
      text,
      style: TextStyle(fontSize: textSize, fontWeight: FontWeight.w600),
    );
  }
}
