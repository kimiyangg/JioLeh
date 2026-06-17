// Shared birthday helpers used by the onboarding and profile-edit forms, so
// the month list and the parsing rules live in exactly one place.

/// Full month names, index 0 = January. The dropdown shows these and
/// [parseBirthday] maps a name back to its 1-based month number.
const kMonthNames = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

/// Builds a [DateTime] from the day / month / year inputs.
///
/// Returns null when every field is empty (birthday is optional). Throws a
/// [FormatException] with a user-facing message when the input is partial
/// (some fields filled, some not) or not a real calendar date (e.g. day 99).
DateTime? parseBirthday({
  required String day,
  required String year,
  required String? month,
}) {
  final dayText = day.trim();
  final yearText = year.trim();
  final hasInput = dayText.isNotEmpty || yearText.isNotEmpty || month != null;
  if (!hasInput) return null;

  final dayValue = int.tryParse(dayText);
  final yearValue = int.tryParse(yearText);
  final monthIndex = month == null ? -1 : kMonthNames.indexOf(month);

  if (dayValue == null || yearValue == null || monthIndex < 0) {
    throw const FormatException('Enter a full birthday or leave it empty.');
  }

  final birthday = DateTime(yearValue, monthIndex + 1, dayValue);
  // DateTime silently rolls overflow over (e.g. day 99 -> next month), so
  // reject anything that didn't round-trip to the exact values entered.
  if (birthday.year != yearValue ||
      birthday.month != monthIndex + 1 ||
      birthday.day != dayValue) {
    throw const FormatException('Enter a valid birthday.');
  }
  return birthday;
}
