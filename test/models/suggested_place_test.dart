import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/models/suggested_place.dart';

void main() {
  group('SuggestedPlace.fromMap', () {
    test('parses a full map with all fields present', () {
      final place = SuggestedPlace.fromMap({
        'place_id': 'place-1',
        'name': 'Tiong Bahru Bakery',
        'category': 'Cafe',
        'latitude': 1.28,
        'longitude': 103.83,
        'avg_friend_rating': 4.5,
        'friend_count': 3,
        'recency_days': 2,
        'pin_count': 10,
        'category_match': true,
      }, score: 2.1);

      expect(place.placeId, 'place-1');
      expect(place.name, 'Tiong Bahru Bakery');
      expect(place.category, 'Cafe');
      expect(place.avgFriendRating, 4.5);
      expect(place.friendCount, 3);
      expect(place.recencyDays, 2);
      expect(place.pinCount, 10);
      expect(place.categoryMatch, isTrue);
      expect(place.score, 2.1);
    });

    test('name falls back to "Unnamed place" when missing', () {
      final place = SuggestedPlace.fromMap({
        'place_id': 'place-1',
        'latitude': 1.28,
        'longitude': 103.83,
      }, score: 0);

      expect(place.name, 'Unnamed place');
    });

    test('friendCount and pinCount default to 0, categoryMatch to false', () {
      final place = SuggestedPlace.fromMap({
        'place_id': 'place-1',
        'latitude': 1.28,
        'longitude': 103.83,
      }, score: 0);

      expect(place.friendCount, 0);
      expect(place.pinCount, 0);
      expect(place.categoryMatch, isFalse);
    });

    test('category, avgFriendRating, and recencyDays are null when absent', () {
      final place = SuggestedPlace.fromMap({
        'place_id': 'place-1',
        'latitude': 1.28,
        'longitude': 103.83,
      }, score: 0);

      expect(place.category, isNull);
      expect(place.avgFriendRating, isNull);
      expect(place.recencyDays, isNull);
    });
  });
}
