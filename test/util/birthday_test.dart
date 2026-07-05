import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/util/birthday.dart';
void main() {
  group('parseBirthday', () {
    test('all field empty returns null', () {
      expect(parseBirthday(day: "", year: "", month: null), null);
    });

    test('throws when day is provided but year and month are not', () {
      expect(
        () => parseBirthday(day: "15", year: "", month: null),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when year is provided but day and month are not', () {
      expect(
        () => parseBirthday(day: "", year: "1995", month: null),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when month is provided but day and year are not', () {
      expect(
        () => parseBirthday(day: "", year: "", month: "January"),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when day and year are provided but month is not', () {
      expect(
        () => parseBirthday(day: "15", year: "1995", month: null),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when day and month are provided but year is not', () {
      expect(
        () => parseBirthday(day: "15", year: "", month: "January"),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when year and month are provided but day is not', () {
      expect(
        () => parseBirthday(day: "", year: "1995", month: "January"),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when day is not numeric', () {
      expect(
        () => parseBirthday(day: "abc", year: "1995", month: "January"),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when year is not numeric', () {
      expect(
        () => parseBirthday(day: "15", year: "abc", month: "January"),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when month is not a valid month name', () {
      expect(
        () => parseBirthday(day: "15", year: "1995", month: "Jan"),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws for April 31st (a day that does not exist)', () {
      expect(
        () => parseBirthday(day: "31", year: "1995", month: "April"),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws for February 30th (a day that does not exist)', () {
      expect(
        () => parseBirthday(day: "30", year: "1995", month: "February"),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws for February 29th on a non-leap year', () {
      expect(
        () => parseBirthday(day: "29", year: "1995", month: "February"),
        throwsA(isA<FormatException>()),
      );
    });

    test('succeeds for February 29th on a leap year', () {
      expect(
        parseBirthday(day: "29", year: "1996", month: "February"),
        DateTime(1996, 2, 29),
      );
    });

    test('returns the correct DateTime for a valid birthday', () {
      expect(
        parseBirthday(day: "15", year: "1995", month: "June"),
        DateTime(1995, 6, 15),
      );
    });

    test('trims whitespace around day and year before parsing', () {
      expect(
        parseBirthday(day: " 15 ", year: " 1995 ", month: "June"),
        DateTime(1995, 6, 15),
      );
    });
  });

  group('formatBirthday', () {
    test('returns an empty string when birthday is null', () {
      expect(formatBirthday(null), "");
    });

    test('formats a valid birthday as "Born {day} {MonAbbr}"', () {
      expect(formatBirthday(DateTime(1995, 6, 15)), "Born 15 Jun");
    });

    test('abbreviates January and December correctly', () {
      expect(formatBirthday(DateTime(2000, 1, 5)), "Born 5 Jan");
      expect(formatBirthday(DateTime(2000, 12, 25)), "Born 25 Dec");
    });
  });
}