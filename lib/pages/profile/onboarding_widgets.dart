import 'package:flutter/material.dart';

import 'package:jio_leh/util/username_rule.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_section_label.dart';
import 'package:jio_leh/widgets/app_text_field.dart';
import 'package:jio_leh/widgets/birthday_row.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final onBoardingTitleSize = context.scaledFont(AppTextSizes.heading);
    final subtitleSize = context.scaledFont(AppTextSizes.subtitle);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(30, 30, 30, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👋", style: TextStyle(fontSize: 40)),
            SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "Welcome! Let's set you up",
                maxLines: 1,
                style: TextStyle(
                  fontSize: onBoardingTitleSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "This is how friends will see in your profile.",
                maxLines: 1,
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: AppColors.lightSubtitle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            const AppSectionLabel("USER ID"),
            const SizedBox(height: 10),
            AppTextField(
              controller: usernameController,
              hintText: UsernameRule.hint,
              inputFormatters: UsernameRule.inputFormatters,
            ),
            const SizedBox(height: 30),
            const AppSectionLabel("YOUR NAME"),
            const SizedBox(height: 10),
            AppTextField(
              controller: displayNameController,
              hintText: "What should we call you?",
            ),
            const SizedBox(height: 30),
            const AppSectionLabel("BIRTHDAY · OPTIONAL"),
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
