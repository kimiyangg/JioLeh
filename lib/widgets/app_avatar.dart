import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

// Atom — the app's circular avatar. The caller resolves the [image] provider (Network/File); this owns the shape, size, background colour, and fallback icon. Pass [onTap] to make it tappable (e.g. a photo picker).
class AppAvatar extends StatelessWidget {
  final double radius;
  final ImageProvider? image;
  final IconData placeholder; // shown when [image] is null
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    required this.radius,
    this.image,
    this.placeholder = Icons.add_a_photo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.darkWidgetBackground,
      foregroundImage: image,
      child: image == null ? Icon(placeholder, color: Colors.white) : null,
    );
    return onTap == null ? avatar : GestureDetector(onTap: onTap, child: avatar);
  }
}
