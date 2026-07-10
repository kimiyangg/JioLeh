import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

/// The white, rounded, shadowed container that sits behind text fields and the month dropdown.
/// 
/// * [child]: The widget to be displayed inside the box.
/// * [height]: The fixed height of the box.
/// * [color]: Optional override for the box's fill color (defaults to [AppColors.lightSection]).
class AppFieldBox extends StatelessWidget {
  const AppFieldBox({super.key, required this.child, this.height, this.color});

  final Widget child;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.lightSection,
        borderRadius: BorderRadius.circular(AppRadii.elements),
        boxShadow: AppShadows.field,
      ),
      child: child,
    );
  }
}
