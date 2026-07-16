import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

/// A horizontally-wrapping row of small read-only tag chips (e.g. AI photo
/// tags). Renders nothing if [tags] is empty.
class TagChipRow extends StatelessWidget {
  const TagChipRow({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final tag in tags)
          Chip(
            label: Text(
              tag,
              style: const TextStyle(fontSize: AppTextSizes.caption),
            ),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            backgroundColor: AppColors.lightSection,
            side: BorderSide.none,
          ),
      ],
    );
  }
}