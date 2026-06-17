import 'package:flutter/material.dart';
 
// The colors used in the app, organized by theme and purpose.
// All colors used in the app should be defined here for consistency and easy maintenance.

class AppColors {
  static const lightBackground = Color(0xfff6e7da);
  static const darkBackground = Color(0xFF1A1212);

  static const lightWidgetBackground = Color(0xFF3E9F6B);
  static const darkWidgetBackground = Color(0xFFE7D5B2);

  static const lightText = Color(0xFF26201E);
  static const darkText = Color(0xFFEDF2E6);

  static const lightWidgetText = Color(0xFF16271B);
  static const darkWidgetText = Color(0xFFFFFFFF);

  static const lightSubtitle = Color(0xFF897568);

  static const disabledButton = Color(0xFF4B443B);

  // Near-black face of the dark buttons (Google sign-in, etc.).
  static const darkButton = Color(0xFF211D18);

  // Destructive action button (e.g. delete account): face + darker shadow.
  static const danger = Color(0xFFD84B3A);
  static const dangerShadow = Color(0xFF9E2F24);

  // Muted greys for secondary text on the auth screens.
  static const taglineText = Color(0xFF776F65);
  static const authBodyText = Color(0xFF7A736A);
}

class LogoColors {
  static const peachLogo = Color(0xFFEEDACA);
  static const forestLogo = Color(0xFF0B3D2E);
}

class AppRadii {
  static const elements = 16.0;
}

class AppShadows {
  static const field = [
    BoxShadow(color: Color(0x0F1E1B16), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

// Standard height for a single-line input field box.
class AppFieldHeights {
  static const single = 55.0;
}

// Height of the main call-to-action buttons.
class AppButtonHeights {
  static const primary = 54.0;
}

// The text sizes used in the app, defined as constants for consistency and easy maintenance.
class AppTextSizes {
  static const heading = 26.0;
  static const subtitle = 18.0;
  static const body = 16.0;
  static const textFieldHint = 16.0;
  static const label = 13.0;
  static const button = 17.0;
  static const caption = 12.0;
}

// Extension on BuildContext to provide responsive text scaling based on screen width.
extension ResponsiveText on BuildContext {
  double scaledFont(double base) {
    final width = MediaQuery.sizeOf(this).width;
    return (width / 390 * base).clamp(base * 0.85, base * 1.15);
  }
}