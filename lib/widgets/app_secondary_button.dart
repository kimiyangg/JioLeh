import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

/// A secondary action button — shorter and with smaller text than
/// [AppPrimaryButton], for paired or inline actions like Edit + Share.
///
/// Width is decided by the parent (wrap in an [Expanded] or [SizedBox]); the
/// button owns its height and text size.
///
/// * [label]: The button text.
/// * [onPressed]: Called on tap. Pass null to disable.
/// * [icon]: Optional leading icon shown before the label.
/// * [backgroundColor]: The button face colour (defaults to the green theme).
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor = AppColors.lightWidgetBackground,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppButtonHeights.compact,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.elements),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppTextSizes.secButton,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
