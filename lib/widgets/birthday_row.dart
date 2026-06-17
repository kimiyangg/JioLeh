import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_field_box.dart';
import 'package:jio_leh/widgets/app_text_field.dart';

/// The day / month / year input row used by birthday fields. The "BIRTHDAY"
/// label above it stays with the form, not here.
///
/// * [dayController]: Controller for the day (DD) field.
/// * [yearController]: Controller for the year (YYYY) field.
/// * [selectedMonth]: The currently selected month, or null if none.
/// * [months]: The month names shown in the dropdown.
/// * [onMonthChanged]: Called when the user picks a different month.
class BirthdayRow extends StatelessWidget {
  const BirthdayRow({
    super.key,
    required this.dayController,
    required this.yearController,
    required this.selectedMonth,
    required this.months,
    required this.onMonthChanged,
  });

  final TextEditingController dayController;
  final TextEditingController yearController;
  final String? selectedMonth;
  final List<String> months;
  final ValueChanged<String?> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final fieldSize = context.scaledFont(AppTextSizes.textFieldHint);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AppTextField(
            controller: dayController,
            hintText: "DD",
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: AppFieldBox(
            height: AppFieldHeights.single,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<String>(
                value: selectedMonth,
                hint: Text(
                  "Month",
                  style: TextStyle(
                    fontSize: fieldSize,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isExpanded: true,
                style: TextStyle(
                  fontSize: fieldSize,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                dropdownColor: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(AppRadii.elements),
                items: months.map((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: onMonthChanged,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: AppTextField(
            controller: yearController,
            hintText: "YYYY",
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
