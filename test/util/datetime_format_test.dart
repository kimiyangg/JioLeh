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
}
