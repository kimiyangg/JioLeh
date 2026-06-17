import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

/// The intent of a snackbar, which drives its colour.
enum SnackBarKind { neutral, error, success }

/// App-wide snackbar styling, so every screen shows the same floating, rounded,
/// colour-coded bar. Call as `context.showAppSnackBar('...')`.
///
/// * [message]: The text to show.
/// * [kind]: Picks the background colour (neutral / error / success).
/// * [action]: Optional trailing button, e.g. "Retry" or "Undo".
extension AppSnackBars on BuildContext {
  void showAppSnackBar(
    String message, {
    SnackBarKind kind = SnackBarKind.neutral,
    SnackBarAction? action,
  }) {
    final backgroundColor = switch (kind) {
      SnackBarKind.neutral => AppColors.darkButton,
      SnackBarKind.error => AppColors.danger,
      SnackBarKind.success => AppColors.lightWidgetBackground,
    };

    final messenger = ScaffoldMessenger.of(this);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: scaledFont(AppTextSizes.body),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.elements),
        ),
        showCloseIcon: true,
        closeIconColor: Colors.white,
        action: action,
      ),
    );
  }
}
