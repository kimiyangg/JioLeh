import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/models/place.dart';

void main() {
  group('Place.fromMap', () {
    test('parses a full map including nested user_pins', () {
      final place = Place.fromMap({
        'id': 'place-1',
        'name': 'Marina Bay Sands',
        'latitude': 1.2834,
        'longitude': 103.8607,
        'pin_count': 3,
        'user_pins': [
          {'id': 'pin-1', 'user_id': 'user-1', 'emoji': 'star'},
        ],
      });

      expect(place.id, 'place-1');
      expect(place.name, 'Marina Bay Sands');
      expect(place.latitude, 1.2834);
      expect(place.longitude, 103.8607);
      expect(place.pinCount, 3);
      expect(place.pins, hasLength(1));
      expect(place.pins.single.id, 'pin-1');
      expect(place.pins.single.userId, 'user-1');
    });

    test('name defaults to "Unnamed place" when missing', () {
      final place = Place.fromMap({'latitude': 1.0, 'longitude': 103.0});

      expect(place.name, 'Unnamed place');
    });

    test('pinCount defaults to 0 when missing', () {
      final place = Place.fromMap({'latitude': 1.0, 'longitude': 103.0});

      expect(place.pinCount, 0);
    });

    test('pins defaults to an empty list when user_pins is missing', () {
      final place = Place.fromMap({'latitude': 1.0, 'longitude': 103.0});

      expect(place.pins, isEmpty);
    });

    test('coerces integer latitude and longitude to double', () {
      final place = Place.fromMap({'latitude': 1, 'longitude': 103});

      expect(place.latitude, 1.0);
      expect(place.longitude, 103.0);
    });

    test('id is null when missing', () {
      final place = Place.fromMap({'latitude': 1.0, 'longitude': 103.0});

      expect(place.id, isNull);
    });

    test('category is parsed when present', () {
      final place = Place.fromMap({
        'latitude': 1.0,
        'longitude': 103.0,
        'category': '☕',
      });

      expect(place.category, '☕');
    });

    test('category is null when missing', () {
      final place = Place.fromMap({'latitude': 1.0, 'longitude': 103.0});

      expect(place.category, isNull);
    });
  });
}
