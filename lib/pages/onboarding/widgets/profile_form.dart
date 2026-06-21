import 'package:flutter/material.dart';

import 'package:jio_leh/util/username_rule.dart';
import 'package:jio_leh/widgets/app_section_label.dart';
import 'package:jio_leh/widgets/app_text_field.dart';
import 'package:jio_leh/widgets/birthday_row.dart';

/// The onboarding profile form: user id, display name, and an optional
/// birthday. Each field is built from the shared design-system widgets
/// ([AppSectionLabel], [AppTextField], [BirthdayRow]).
///
/// * [usernameController]: Controller for the user id field.
/// * [displayNameController]: Controller for the display name field.
/// * [dayController]: Controller for the birthday day (DD) field.
/// * [yearController]: Controller for the birthday year (YYYY) field.
/// * [selectedMonth]: The currently selected birthday month, or null.
/// * [onMonthChanged]: Called when the user picks a different month.
class ProfileForm extends StatelessWidget {
  const ProfileForm({
    super.key,
    required this.usernameController,
    required this.displayNameController,
    required this.dayController,
    required this.yearController,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  final TextEditingController usernameController;
  final TextEditingController displayNameController;
  final TextEditingController dayController;
  final TextEditingController yearController;
  final String? selectedMonth;
  final ValueChanged<String?> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionLabel(text: "USER ID"),
            const SizedBox(height: 10),
            AppTextField(
              controller: usernameController,
              hintText: UsernameRule.hint,
              inputFormatters: UsernameRule.inputFormatters,
            ),
            const SizedBox(height: 30),
            const AppSectionLabel(text: "YOUR NAME"),
            const SizedBox(height: 10),
            AppTextField(
              controller: displayNameController,
              hintText: "What should we call you?",
            ),
            const SizedBox(height: 30),
            const AppSectionLabel(text: "BIRTHDAY · OPTIONAL"),
            const SizedBox(height: 10),
            BirthdayRow(
              dayController: dayController,
              yearController: yearController,
              selectedMonth: selectedMonth,
              onMonthChanged: onMonthChanged,
            ),
          ],
        ),
      ),
    );
  }
}
