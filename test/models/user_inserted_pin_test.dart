import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/models/user_inserted_pin.dart';

void main() {
  group('UserInsertedPin.placeToMap', () {
    test('uses formalName when present', () {
      const pin = UserInsertedPin(
        latitude: 1.3521,
        longitude: 103.8198,
        formalName: ' Marina Bay ',
        customName: 'My Bay',
        emoji: 'pin',
      );

      final map = pin.placeToMap('user-123');

      expect(map['name'], 'Marina Bay');
      expect(map['latitude'], 1.3521);
      expect(map['longitude'], 103.8198);
      expect(map['created_by'], 'user-123');
      expect(map['source'], 'user');
      expect(map['status'], 'pending');
      expect(map.containsKey('photo_paths'), isFalse);
    });

    test('throws when formalName is blank', () {
      const pin = UserInsertedPin(
        latitude: 1.3521,
        longitude: 103.8198,
        formalName: '   ',
        customName: ' My favorite spot ',
        emoji: 'pin',
      );

      expect(() => pin.placeToMap('user-123'), throwsA(isA<ArgumentError>()));
    });

    test('does not use customName as the place name', () {
      const pin = UserInsertedPin(
        latitude: 1.3521,
        longitude: 103.8198,
        formalName: ' Marina Bay ',
        customName: ' My favorite spot ',
        emoji: 'pin',
      );

      final map = pin.placeToMap('user-123');

      expect(map['name'], 'Marina Bay');
    });
  });

  group('UserInsertedPin.pinToMap', () {
    test('maps user-specific fields to user_pins columns', () {
      const pin = UserInsertedPin(
        latitude: 1.3521,
        longitude: 103.8198,
        formalName: 'Marina Bay',
        customName: ' My Bay ',
        emoji: 'pin',
        rating: 4,
        review: ' Great view. ',
      );

      final map = pin.pinToMap('user-123', 'place-123');

      expect(map['user_id'], 'user-123');
      expect(map['place_id'], 'place-123');
      expect(map['custom_name'], 'My Bay');
      expect(map['emoji'], 'pin');
      expect(map['ratings'], 4);
      expect(map['reviews'], 'Great view.');
      expect(map.containsKey('rating'), isFalse);
      expect(map.containsKey('review'), isFalse);
      expect(map.containsKey('photo_paths'), isFalse);
    });

    test('stores blank customName, review, and unrated rating as null', () {
      const pin = UserInsertedPin(
        latitude: 1.3521,
        longitude: 103.8198,
        formalName: 'Marina Bay',
        customName: '   ',
        emoji: 'pin',
        review: '   ',
      );

      final map = pin.pinToMap('user-123', 'place-123');

      expect(map['custom_name'], isNull);
      expect(map['reviews'], isNull);
      expect(map['ratings'], isNull);
    });

    test('allows ratings from 1 to 5', () {
      const pin = UserInsertedPin(
        latitude: 1.3521,
        longitude: 103.8198,
        formalName: 'Marina Bay',
        emoji: 'pin',
        rating: 5,
      );

      final map = pin.pinToMap('user-123', 'place-123');

      expect(map['ratings'], 5);
    });
  });
}
