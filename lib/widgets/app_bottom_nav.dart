import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

// A single tab in the bottom navigation bar.
class AppNavItem {
  final IconData icon;
  final String label;
  const AppNavItem({required this.icon, required this.label});
}

// The app's bottom navigation bar: a row of [items] split around a raised
// center action button (the green "+"). The center button is an action, not a
// tab, so it is reported separately via [onCenterTap].
class AppBottomNav extends StatelessWidget {
  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterTap;

  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    // Items split into the halves that sit left/right of the "+" (even count).
    final half = items.length ~/ 2;

    return MediaQuery.removePadding(
    context: context,
    removeBottom: true,
      child: Padding(
        // Wider left/right, and pushed lower so it covers the Mapbox logo/info.
        // Increase bottom to lift it; decrease bottom to move it lower.
        padding: const EdgeInsets.fromLTRB(8.5, 0, 8.5, 20),
        child: Material(
          color: AppColors.lightSection,
          elevation: AppNavBar.elevation,
          borderRadius: BorderRadius.circular(AppNavBar.radius),
          clipBehavior: Clip.antiAlias, // clips the InkWell ripple to the pill
          child: SizedBox(
            height: AppNavBar.height,
            child: Row(
              children: [
                for (var i = 0; i < half; i++) Expanded(child: _tab(i)),
                _centerButton(),
                for (var i = half; i < items.length; i++) Expanded(child: _tab(i)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(int index) {
    final selected = index == currentIndex;
    final color =
        selected ? AppColors.lightWidgetBackground : AppColors.lightSubtitle;
    final item = items[index];

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: AppNavBar.iconSize, color: color),
          const SizedBox(height: AppNavBar.gap),
          Text(
            item.label,
            style: TextStyle(
              fontSize: AppNavBar.labelSize,
              color: color,
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  Widget _centerButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppNavBar.addButtonGap),
      child: GestureDetector(
        onTap: onCenterTap,
        child: Container(
          width: AppNavBar.addButtonSize,
          height: AppNavBar.addButtonSize,
          decoration: BoxDecoration(
            color: AppColors.lightWidgetBackground,
            borderRadius: BorderRadius.circular(AppNavBar.addButtonRadius),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
