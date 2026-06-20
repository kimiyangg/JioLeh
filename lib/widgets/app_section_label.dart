import 'package:flutter/material.dart';
import 'package:jio_leh/theme.dart';

/// A small, bold, greyish label used to identify sections or fields in a form.
/// Typically placed directly above an [AppFieldBox].
/// 
/// * [text]: The string to be displayed as the label.
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textSize = context.scaledFont(AppTextSizes.label);

    return Text(
      text,
      style: TextStyle(
        fontSize: textSize,
        color: AppColors.lightSubtitle,
        fontWeight: FontWeight.bold,
      )
    );
  }
}