import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

/// The app's main call-to-action button: a lifted button with a solid drop
/// shadow. Defaults to the forest-green theme; pass [backgroundColor]/[liftColor]
/// for other skins. Shows a spinner and blocks taps while [isLoading].
///
/// * [label]: The button text.
/// * [onPressed]: Called on tap. Pass null to disable; ignored while loading.
/// * [icon]: Optional leading icon (font glyph) shown before the label.
/// * [leading]: Optional leading widget; takes precedence over [icon] when set.
/// * [isLoading]: When true, shows a spinner instead of the label and disables taps.
/// * [backgroundColor]: The button face colour.
/// * [liftColor]: The solid drop-shadow colour that gives the lifted look.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.leading,
    this.isLoading = false,
    this.backgroundColor = AppColors.lightWidgetBackground,
    this.liftColor = LogoColors.forestLogo,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? leading;
  final bool isLoading;
  final Color backgroundColor;
  final Color liftColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: liftColor,
        borderRadius: BorderRadius.circular(AppRadii.elements),
        boxShadow: [
          BoxShadow(
            color: liftColor,
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppButtonHeights.primary,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.disabledButton,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.elements),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: AppTextSizes.button,
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
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 8),
                    ] else if (icon != null) ...[
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
