import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/util/username_rule.dart';

void main() {
  group('isValid', () {
    test('accepts the minimum length of 3', () {
      expect(UsernameRule.isValid('abc'), isTrue);
    });

    test('accepts the maximum length of 15', () {
      expect(UsernameRule.isValid('abcdefghijklmno'), isTrue);
    });

    test('rejects one character below the minimum length', () {
      expect(UsernameRule.isValid('ab'), isFalse);
    });

    test('rejects one character above the maximum length', () {
      expect(UsernameRule.isValid('abcdefghijklmnop'), isFalse);
    });

    test('rejects an empty string', () {
      expect(UsernameRule.isValid(''), isFalse);
    });

    test('rejects uppercase letters', () {
      expect(UsernameRule.isValid('aBc'), isFalse);
    });

    test('rejects symbols', () {
      expect(UsernameRule.isValid('ab-c'), isFalse);
    });

    test('rejects spaces', () {
      expect(UsernameRule.isValid('ab c'), isFalse);
    });
  });

  group('generate', () {
    test('always generates a valid username of the correct length', () {
      for (var i = 0; i < 20; i++) {
        final username = UsernameRule.generate();
        expect(username.length, UsernameRule.generatedLength);
        expect(UsernameRule.isValid(username), isTrue);
      }
    });
  });

  group('inputFormatters', () {
    test('filters disallowed characters and truncates to maxLength', () {
      final formatters = UsernameRule.inputFormatters;
      const oldValue = TextEditingValue.empty;
      var newValue = const TextEditingValue(
        text: 'aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpP',
      );

      for (final formatter in formatters) {
        newValue = formatter.formatEditUpdate(oldValue, newValue);
      }

      expect(newValue.text, 'abcdefghijklmno');
    });
  });
}
