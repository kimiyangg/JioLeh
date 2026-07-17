import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

/// A row of small read-only tag chips (e.g. AI photo tags). Wraps onto
/// multiple lines by default; [scrollable] keeps a single horizontally
/// scrolling line instead. Renders nothing if [tags] is empty.
class TagChipRow extends StatelessWidget {
  const TagChipRow({super.key, required this.tags, this.scrollable = false});

  final List<String> tags;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < tags.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              _chip(tags[i]),
            ],
          ],
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [for (final tag in tags) _chip(tag)],
    );
  }

  Widget _chip(String tag) {
    return Chip(
      label: Text(
        tag,
        style: const TextStyle(fontSize: AppTextSizes.caption),
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      backgroundColor: AppColors.lightSection,
      side: BorderSide.none,
    );
  }
}