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

    test('parses sentiment_label and sentiment_score when present', () {
      final pin = UserPin.fromMap({
        'user_id': 'user-1',
        'sentiment_label': 'POSITIVE',
        'sentiment_score': 0.9,
      });

      expect(pin.sentimentLabel, 'POSITIVE');
      expect(pin.sentimentScore, 0.9);
    });
  });

  group('UserPin.sentiment', () {
    UserPin pinWith({String? label, double? score}) => UserPin(
          userId: 'u1',
          emoji: 'pin',
          sentimentLabel: label,
          sentimentScore: score,
        );

    test('null when both sentimentLabel and sentimentScore are absent', () {
      expect(pinWith().sentiment, isNull);
    });

    test('null when only sentimentLabel is set', () {
      expect(pinWith(label: 'POSITIVE').sentiment, isNull);
    });

    test('null when only sentimentScore is set', () {
      expect(pinWith(score: 0.9).sentiment, isNull);
    });

    test('positive when score is exactly the 0.8 threshold', () {
      expect(
        pinWith(label: 'POSITIVE', score: 0.8).sentiment,
        PinSentiment.positive,
      );
    });

    test('mixed when score is just under the 0.8 threshold', () {
      expect(
        pinWith(label: 'POSITIVE', score: 0.7999).sentiment,
        PinSentiment.mixed,
      );
    });

    test('negative when label is NEGATIVE with high confidence', () {
      expect(
        pinWith(label: 'NEGATIVE', score: 0.9).sentiment,
        PinSentiment.negative,
      );
    });

    test('mixed when label is NEGATIVE with low confidence', () {
      expect(
        pinWith(label: 'NEGATIVE', score: 0.6).sentiment,
        PinSentiment.mixed,
      );
    });
  });
}
