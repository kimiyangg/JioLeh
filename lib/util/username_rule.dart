import 'dart:math';

import 'package:flutter/services.dart';

/// Helping class for full username rules and texts to display during error handling
class UsernameRule {
  // When using DONT create an instance (don't do UsernameRule())
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

  /// Generates a random username, used as a fallback method for default usernames
  /// 
  /// Returns an 8 character String password that follows the username rules
  static String generate() {
    final random = Random();
    String code = '';
    for (var i = 0; i < generatedLength; i++) {
      code += _alphabet[random.nextInt(_alphabet.length)];
    }
    return code;
  }

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
