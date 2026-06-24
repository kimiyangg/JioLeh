import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_field_box.dart';

/// A single styled input field: a borderless TextField inside.
/// 
/// * [controller]: The controller for the text being edited.
/// * [hintText]: Text that suggests what sort of input the field accepts.
/// * [height]: The height of the input box, defaults to [AppFieldHeights.single].
/// * [keyboardType]: The type of information for which to optimize the text input control.
/// * [inputFormatters]: Optional input formatters to restrict or format the text.
/// * [maxLines]: The maximum number of lines to show at one time, defaults to 1.
/// * [onSubmitted]: Called when the user submits the field from the keyboard.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.height = AppFieldHeights.single,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.readOnly = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final double height;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final bool readOnly;
  final ValueChanged<String>? onSubmitted;
  
  @override
  Widget build(BuildContext context) {
    final hintSize = context.scaledFont(AppTextSizes.textFieldHint);

    return AppFieldBox(
      height: height,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        readOnly: readOnly,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: hintSize,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}
