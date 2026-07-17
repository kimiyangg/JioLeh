import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/models/user_pin.dart';
import 'package:jio_leh/pages/map/shared_place_details_page_model.dart';

import '../../services/fakes/fake_account_service.dart';
import '../../services/fakes/fake_auth_service.dart';
import '../../services/fakes/fake_pin_service.dart';

UserPin _pin(String userId, {int? rating, List<String> tags = const []}) =>
    UserPin(userId: userId, emoji: '🍽️', rating: rating, aiTags: tags);

Place _place(List<UserPin> pins) =>
    Place(name: 'Test Place', latitude: 1.3, longitude: 103.8, pins: pins);

SharedPlaceDetailsPageModel _buildModel(
  Place place, {
  List<String> photoUrls = const [],
}) {
  return SharedPlaceDetailsPageModel(
    place: place,
    account: FakeAccountService(),
    pins: FakePinService(photoUrls: photoUrls),
    auth: FakeAuthService(),
  );
}

void main() {
  group('averageRating', () {
    test('averages all rated pins', () async {
      final model = _buildModel(
        _place([
          _pin('a', rating: 5),
          _pin('b', rating: 4),
          _pin('c', rating: 4),
        ]),
      );
      await model.load();

      expect(model.averageRating, closeTo(4.33, 0.01));
      expect(model.ratingCount, 3);
    });

    test('skips unrated pins', () async {
      final model = _buildModel(_place([_pin('a', rating: 5), _pin('b')]));
      await model.load();

      expect(model.averageRating, 5.0);
      expect(model.ratingCount, 1);
    });

    test('is null when no pin has a rating', () async {
      final model = _buildModel(_place([_pin('a'), _pin('b')]));
      await model.load();

      expect(model.averageRating, null);
      expect(model.ratingCount, 0);
    });

    test('single pin with rating 0 averages to 0', () async {
      final model = _buildModel(_place([_pin('a', rating: 0)]));
      await model.load();

      expect(model.averageRating, 0.0);
      expect(model.ratingCount, 1);
    });
  });

  group('allPhotoUrls', () {
    test('merges photos from every entry', () async {
      final model = _buildModel(
        _place([_pin('a'), _pin('b')]),
        photoUrls: ['u1', 'u2'],
      );
      await model.load();

      expect(model.allPhotoUrls, ['u1', 'u2', 'u1', 'u2']);
    });

    test('is empty when no entry has photos', () async {
      final model = _buildModel(_place([_pin('a'), _pin('b')]));
      await model.load();

      expect(model.allPhotoUrls, isEmpty);
    });

    test('with a single entry returns just its photos', () async {
      final model = _buildModel(
        _place([_pin('a')]),
        photoUrls: ['u1', 'u2', 'u3'],
      );
      await model.load();

      expect(model.allPhotoUrls, ['u1', 'u2', 'u3']);
    });
  });

  group('allTags', () {
    test('deduplicates across friends preserving first-seen order', () async {
      final model = _buildModel(
        _place([
          _pin('a', tags: ['food', 'noodle']),
          _pin('b', tags: ['noodle', 'soup']),
        ]),
      );
      await model.load();

      expect(model.allTags, ['food', 'noodle', 'soup']);
    });

    test('is empty when no pin has tags', () async {
      final model = _buildModel(_place([_pin('a'), _pin('b')]));
      await model.load();

      expect(model.allTags, isEmpty);
    });
  });
}
