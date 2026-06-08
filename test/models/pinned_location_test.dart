import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/models/pinned_location.dart';

void main() {
  group('PinnedLocation.fromMap', () {
    test('parses a full row loaded from the database', () {
      final map = {
        'id': 'pin-1',
        'latitude': 1.3521,
        'longitude': 103.8198,
        'name': 'Marina Bay',
        'emoji': '📍',
      };

      final pin = PinnedLocation.fromMap(map);

      expect(pin.id, 'pin-1');
      expect(pin.latitude, 1.3521);
      expect(pin.longitude, 103.8198);
      expect(pin.name, 'Marina Bay');
      expect(pin.emoji, '📍');
    });

    test('coerces integer lat/lng to double', () {
      // Postgres can return whole numbers as int; fromMap uses (num).toDouble().
      final map = {
        'id': 'pin-2',
        'latitude': 1,
        'longitude': 103,
        'name': 'Somewhere',
        'emoji': '🏠',
      };

      final pin = PinnedLocation.fromMap(map);

      expect(pin.latitude, isA<double>());
      expect(pin.latitude, 1.0);
      expect(pin.longitude, 103.0);
    });

    test('allows a null id (client-side draft before saving)', () {
      final map = {
        'id': null,
        'latitude': 1.0,
        'longitude': 103.0,
        'name': 'Draft',
        'emoji': '✏️',
      };

      final pin = PinnedLocation.fromMap(map);

      expect(pin.id, isNull);
    });
  });

  group('PinnedLocation.toMap', () {
    test('includes user_id and omits id', () {
      const pin = PinnedLocation(
        latitude: 1.3521,
        longitude: 103.8198,
        name: 'Marina Bay',
        emoji: '📍',
      );

      final map = pin.toMap('user-123');

      expect(map['user_id'], 'user-123');
      expect(map['name'], 'Marina Bay');
      expect(map['emoji'], '📍');
      expect(map['latitude'], 1.3521);
      expect(map['longitude'], 103.8198);
      // id is assigned by the database, so it must not be sent on insert.
      expect(map.containsKey('id'), isFalse);
    });
  });
}
