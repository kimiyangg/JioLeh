import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/models/user_pin.dart';

void main() {
  group('UserPin.fromMap', () {
    test('parses a full map with all fields present', () {
      final pin = UserPin.fromMap({
        'id': 'pin-1',
        'user_id': 'user-1',
        'place_id': 'place-1',
        'custom_name': 'My favorite spot',
        'emoji': 'star',
        'ratings': 4,
        'reviews': 'Great view.',
        'photo_paths': ['photo1.jpg', 'photo2.jpg'],
        'is_private': true,
      });

      expect(pin.id, 'pin-1');
      expect(pin.userId, 'user-1');
      expect(pin.placeId, 'place-1');
      expect(pin.customName, 'My favorite spot');
      expect(pin.emoji, 'star');
      expect(pin.rating, 4);
      expect(pin.review, 'Great view.');
      expect(pin.photoPaths, ['photo1.jpg', 'photo2.jpg']);
      expect(pin.isPrivate, isTrue);
    });

    test('emoji defaults to "pin" when missing', () {
      final pin = UserPin.fromMap({'user_id': 'user-1'});

      expect(pin.emoji, 'pin');
    });

    test('isPrivate defaults to false when missing', () {
      final pin = UserPin.fromMap({'user_id': 'user-1'});

      expect(pin.isPrivate, isFalse);
    });

    test('photoPaths defaults to an empty list when missing', () {
      final pin = UserPin.fromMap({'user_id': 'user-1'});

      expect(pin.photoPaths, isEmpty);
    });

    test('photoPaths elements are coerced to strings', () {
      final pin = UserPin.fromMap({
        'user_id': 'user-1',
        'photo_paths': [123, true],
      });

      expect(pin.photoPaths, ['123', 'true']);
    });

    test('id, placeId, customName, rating, and review are null when absent', () {
      final pin = UserPin.fromMap({'user_id': 'user-1'});

      expect(pin.id, isNull);
      expect(pin.placeId, isNull);
      expect(pin.customName, isNull);
      expect(pin.rating, isNull);
      expect(pin.review, isNull);
    });
  });
}
