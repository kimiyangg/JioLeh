import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

/// The app's main call-to-action button: a forest-green "lifted" button with a
/// solid drop shadow. Shows a spinner and blocks taps while [isLoading].
///
/// * [label]: The button text.
/// * [onPressed]: Called on tap. Pass null to disable; ignored while loading.
/// * [icon]: Optional leading icon shown before the label.
/// * [isLoading]: When true, shows a spinner instead of the label and disables taps.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: LogoColors.forestLogo,
        borderRadius: BorderRadius.circular(AppRadii.elements),
        boxShadow: const [
          BoxShadow(
            color: LogoColors.forestLogo,
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppButtonHeights.primary,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.lightWidgetBackground,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.disabledButton,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.elements),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(label),
                  ],
                ),
        ),
      ),
    );
  }
}
