import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/models/nearby_place.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/pages/invitations/open_jio_form_page_model.dart';
import 'package:jio_leh/services/location_service.dart';

import '../../services/fakes/fake_pin_service.dart';
import '../../services/fakes/fake_place_service.dart';

const _providerPlace = NearbyPlace(
  placeId: 'google-1',
  name: 'Lau Pa Sat',
  latitude: 1.28,
  longitude: 103.85,
);

const _existingPlace = Place(
  id: 'db-place-1',
  name: 'Lau Pa Sat',
  latitude: 1.28,
  longitude: 103.85,
);

void main() {
  late FakePinService pins;
  late OpenJioFormPageModel model;

  setUp(() {
    pins = FakePinService();
    model = OpenJioFormPageModel(
      place: FakePlaceService(),
      pins: pins,
      location: LocationService(),
    );
  });

  group('resolvePlaceId', () {
    test('returns null when no place is selected', () async {
      expect(await model.resolvePlaceId(), isNull);
      expect(pins.getOrCreateProviderPlaceIdCalls, 0);
    });

    test('returns the db id directly for an existing place', () async {
      model.selectExistingPlace(_existingPlace);

      expect(await model.resolvePlaceId(), 'db-place-1');
      expect(pins.getOrCreateProviderPlaceIdCalls, 0);
    });

    test('find-or-creates a provider place and returns its id', () async {
      pins.providerPlaceIdResult = 'db-place-2';
      model.selectPlace(_providerPlace);

      expect(await model.resolvePlaceId(), 'db-place-2');
      expect(pins.getOrCreateProviderPlaceIdCalls, 1);
      expect(pins.lastGetOrCreatePlace, _providerPlace);
    });

    test('returns null when the provider place id is empty', () async {
      model.selectPlace(const NearbyPlace(
        placeId: '',
        name: 'Somewhere',
        latitude: 1,
        longitude: 103,
      ));

      expect(await model.resolvePlaceId(), isNull);
      expect(pins.getOrCreateProviderPlaceIdCalls, 0);
    });

    test('returns null when find-or-create throws', () async {
      pins.throwOnGetOrCreateProviderPlaceId = true;
      model.selectPlace(_providerPlace);

      expect(await model.resolvePlaceId(), isNull);
    });

    test('a provider selection after an existing one drops the stale db id', () async {
      pins.providerPlaceIdResult = 'db-place-2';
      model.selectExistingPlace(_existingPlace);
      model.selectPlace(_providerPlace);

      expect(await model.resolvePlaceId(), 'db-place-2');
    });
  });
}
