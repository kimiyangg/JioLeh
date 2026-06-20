import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_field_box.dart';

/// A standard page header: a bold screen [title] on the left and a white
/// close (✕) button on the right that pops the current route.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final titleSize = context.scaledFont(AppTextSizes.heading) + 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: SizedBox(
            width: 44,
            child: AppFieldBox(
              height: 44,
              child: const Center(
                child: Icon(Icons.close, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
