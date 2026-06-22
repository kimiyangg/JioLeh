import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

// A single segment in an [AppSelectionBar]: a label and an optional badge count.
class AppSelectionItem {
  final String label;
  final int badgeCount; // 0 = no badge
  const AppSelectionItem({required this.label, this.badgeCount = 0});
}

// A pill-style segmented selector: a row of [items], one selected at a time. Controlled like [AppBottomNav] — holds no state; the parent passes [selectedIndex] in and is told of taps via [onChanged].
class AppSelectionBar extends StatelessWidget {
  final List<AppSelectionItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const AppSelectionBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Each segment is its own standalone bubble; no shared track behind them.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(items.length, _segment),
    );
  }

  // One selectable segment. Selection is derived (its index vs the passed-in selectedIndex), not stored.
  Widget _segment(int index) {
    final item = items[index];
    final selected = index == selectedIndex;

    return GestureDetector(
      onTap: () => onChanged(index),
      child: AnimatedContainer(
        duration: AppSelBar.animation,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSelBar.segmentPadH,
          vertical: AppSelBar.segmentPadV,
        ),
        margin: const EdgeInsets.only(right: AppSelBar.segmentGap),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.lightWidgetBackground : AppColors.lightSection,
          borderRadius: BorderRadius.circular(AppSelBar.segmentRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.label,
              style: TextStyle(
                color:
                    selected ? AppColors.lightSection : AppColors.lightSubtitle,
                fontWeight: FontWeight.w600,
                fontSize: AppSelBar.labelSize,
              ),
            ),
            if (item.badgeCount > 0) ...[
              const SizedBox(width: AppSelBar.labelGap),
              _badge(item.badgeCount),
            ],
          ],
        ),
      ),
    );
  }

  // A small count bubble. Uses the danger colour so it stays visible on the green selected pill.
  Widget _badge(int count) {
    return Container(
      padding: const EdgeInsets.all(AppSelBar.badgePad),
      constraints: const BoxConstraints(
        minWidth: AppSelBar.badgeMinSize,
        minHeight: AppSelBar.badgeMinSize,
      ),
      decoration: const BoxDecoration(
        color: AppColors.danger,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.lightSection,
          fontSize: AppSelBar.badgeTextSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
