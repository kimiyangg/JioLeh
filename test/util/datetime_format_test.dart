import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/util/datetime_format.dart';

void main() {
  group('formatDateTime', () {
    test('midnight formats as 12 AM', () {
      expect(
        formatDateTime(DateTime(2024, 1, 1, 0, 0)),
        'Mon, 1 Jan · 12:00 AM',
      );
    });

    test('noon formats as 12 PM', () {
      expect(
        formatDateTime(DateTime(2024, 1, 1, 12, 0)),
        'Mon, 1 Jan · 12:00 PM',
      );
    });

    test('a single-digit minute is zero-padded', () {
      expect(
        formatDateTime(DateTime(2024, 1, 1, 9, 5)),
        'Mon, 1 Jan · 9:05 AM',
      );
    });

    test('Sunday does not overflow the days array', () {
      expect(
        formatDateTime(DateTime(2024, 1, 7, 10, 30)),
        'Sun, 7 Jan · 10:30 AM',
      );
    });

    test('January and December abbreviate correctly', () {
      expect(
        formatDateTime(DateTime(2024, 1, 15, 8, 0)),
        'Mon, 15 Jan · 8:00 AM',
      );
      expect(
        formatDateTime(DateTime(2024, 12, 25, 8, 0)),
        'Wed, 25 Dec · 8:00 AM',
      );
    });

    test('ordinary hours land in the correct AM/PM partition', () {
      expect(
        formatDateTime(DateTime(2024, 1, 1, 9, 0)),
        'Mon, 1 Jan · 9:00 AM',
      );
      expect(
        formatDateTime(DateTime(2024, 1, 1, 15, 0)),
        'Mon, 1 Jan · 3:00 PM',
      );
    });
  });

  group('formatRelativeDateTime', () {
    final now = DateTime(2024, 1, 15, 12, 0);

    test('same day, morning, formats as Today', () {
      expect(
        formatRelativeDateTime(DateTime(2024, 1, 15, 8, 30), now: now),
        'Today · 8:30 AM',
      );
    });

    test('same day, exactly 5 PM, formats as Tonight', () {
      expect(
        formatRelativeDateTime(DateTime(2024, 1, 15, 17, 0), now: now),
        'Tonight · 5:00 PM',
      );
    });

    test('same day, one minute before 5 PM, still formats as Today', () {
      expect(
        formatRelativeDateTime(DateTime(2024, 1, 15, 16, 59), now: now),
        'Today · 4:59 PM',
      );
    });

    test('next calendar day formats as Tomorrow', () {
      expect(
        formatRelativeDateTime(DateTime(2024, 1, 16, 9, 0), now: now),
        'Tomorrow · 9:00 AM',
      );
    });

    test('two days ahead falls back to the full weekday format', () {
      expect(
        formatRelativeDateTime(DateTime(2024, 1, 17, 9, 0), now: now),
        'Wed, 17 Jan · 9:00 AM',
      );
    });

    test('a day in the past falls back to the full weekday format', () {
      expect(
        formatRelativeDateTime(DateTime(2024, 1, 14, 9, 0), now: now),
        'Sun, 14 Jan · 9:00 AM',
      );
    });

    test('midnight on the same day formats as Today · 12:00 AM', () {
      expect(
        formatRelativeDateTime(DateTime(2024, 1, 15, 0, 0), now: now),
        'Today · 12:00 AM',
      );
    });

    test('tomorrow across a month boundary still formats as Tomorrow', () {
      final monthEnd = DateTime(2024, 1, 31, 23, 0);
      expect(
        formatRelativeDateTime(DateTime(2024, 2, 1, 0, 30), now: monthEnd),
        'Tomorrow · 12:30 AM',
      );
    });
  });
}
