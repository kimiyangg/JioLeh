import 'package:flutter/services.dart';

/// Single source of truth for the username rule: 3–10 lowercase letters or
/// digits. The field's hint, input formatters, and submit-time validation all
/// derive from here, so the rule can never drift across the three places.
class UsernameRule {
  const UsernameRule._();

  static const minLength = 3;
  static const maxLength = 15;
  static const _charClass = '[a-z0-9]';

  /// Matches a single allowed character (used by the input formatter).
  static final allowedChars = RegExp(_charClass);

  /// Full-string check used at submit time.
  static final _full = RegExp('^$_charClass{$minLength,$maxLength}\$');

  static bool isValid(String username) => _full.hasMatch(username);

  /// Hint copy, built from the numbers so it never goes stale.
  static const hint = '$minLength-$maxLength lowercase letters or digits';

  /// Error shown when validation fails.
  static const errorMessage =
      'Username must be $minLength-$maxLength letters or digits.';

  /// Formatters for the text field: allowed charset + max length.
  static List<TextInputFormatter> get inputFormatters => [
        FilteringTextInputFormatter.allow(allowedChars),
        LengthLimitingTextInputFormatter(maxLength),
      ];
}
