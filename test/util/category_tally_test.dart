import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/models/user_pin.dart';
import 'package:jio_leh/util/category_tally.dart';

UserPin _pin(String emoji, DateTime createdAt) {
  return UserPin(userId: 'user', emoji: emoji, createdAt: createdAt);
}

void main() {
  group('computeCategory', () {
    test('returns null for an empty list', () {
      expect(computeCategory([]), isNull);
    });

    test('returns the only category for a single pin', () {
      final pins = [_pin('🍽️', DateTime(2026, 1, 1))];

      expect(computeCategory(pins), '🍽️');
    });

    test('returns the clear majority category', () {
      final pins = [
        _pin('☕', DateTime(2026, 1, 1)),
        _pin('☕', DateTime(2026, 1, 2)),
        _pin('☕', DateTime(2026, 1, 3)),
        _pin('🍽️', DateTime(2026, 1, 4)),
      ];

      expect(computeCategory(pins), '☕');
    });

    test('two-way tie: side with the newer pin wins (newer is drinks)', () {
      final pins = [
        _pin('☕', DateTime(2026, 1, 1)),
        _pin('☕', DateTime(2026, 1, 2)),
        _pin('🍹', DateTime(2026, 1, 3)),
        _pin('🍹', DateTime(2026, 1, 10)),
      ];

      expect(computeCategory(pins), '🍹');
    });

    test('two-way tie: side with the newer pin wins (newer is cafe)', () {
      final pins = [
        _pin('☕', DateTime(2026, 1, 1)),
        _pin('☕', DateTime(2026, 1, 10)),
        _pin('🍹', DateTime(2026, 1, 2)),
        _pin('🍹', DateTime(2026, 1, 3)),
      ];

      expect(computeCategory(pins), '☕');
    });

    test('N-way tie breaks by most recently created pin', () {
      final pins = [
        _pin('☕', DateTime(2026, 1, 1)),
        _pin('🍽️', DateTime(2026, 1, 2)),
        _pin('🍹', DateTime(2026, 1, 3)),
      ];

      expect(computeCategory(pins), '🍹');
    });

    test('majority is found even when it is not first in the list', () {
      final pins = [
        _pin('🍽️', DateTime(2026, 1, 1)),
        _pin('☕', DateTime(2026, 1, 2)),
        _pin('☕', DateTime(2026, 1, 3)),
        _pin('☕', DateTime(2026, 1, 4)),
      ];

      expect(computeCategory(pins), '☕');
    });
  });
}
