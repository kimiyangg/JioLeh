import 'dart:math';

import 'package:flutter/services.dart';

/// Username rules such as the field's hint, input formatters, submit-time validation,
/// and the auto-generated fallback all derive from here, so the rule can never drift.
class UsernameRule {
  // all static here, so just call UsernameRule.generate() / .isValid(...) —
  // When using DONT create an instance (don't do UsernameRule()).
  // this class is intended to work like the math lib in java cs2030s as a static only class
  // Private Constructor: no other file can call it to create instance obj
  const UsernameRule._();

  static const minLength = 3;
  static const maxLength = 15;
  static const _charClass = '[a-z0-9]';

  /// The characters an auto-generated username is built from — the explicit
  /// form of [_charClass], kept beside it so the two can't drift.
  static const _alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';

  /// Length of an auto-generated username (within [minLength]–[maxLength]).
  static const generatedLength = 8;

  /// Matches a single allowed character (used by the input formatter).
  static final allowedChars = RegExp(_charClass);

  /// Full-string check used at submit time.
  static final _full = RegExp('^$_charClass{$minLength,$maxLength}\$');

  static bool isValid(String username) => _full.hasMatch(username);

  /// Generates a random username that satisfies this rule.
  static String generate() {
    final random = Random();
    String code = '';
    for (var i = 0; i < generatedLength; i++) {
      code += _alphabet[random.nextInt(_alphabet.length)];
    }
    return code;
  }

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
