import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/models/nearby_place.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/pages/map/location_form_page_model.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';

import '../../services/fakes/fake_pin_service.dart';
import '../../services/fakes/fake_place_service.dart';

void main() {
  LocationFormPageModel buildModel({FakePinService? pins}) {
    final model = LocationFormPageModel(
      place: FakePlaceService(),
      pins: pins ?? FakePinService(),
      selectedType: PinType.restaurant,
      latitude: 1.35,
      longitude: 103.82,
    );
    model.start();
    return model;
  }

  group('selectExistingPlace', () {
    test('pre-fills currentType from the place category', () {
      final model = buildModel();

      model.selectExistingPlace(
        const Place(
          id: 'place-1',
          name: 'Kopi Place',
          latitude: 1.35,
          longitude: 103.82,
          category: '☕',
        ),
      );

      expect(model.currentType, PinType.cafe);
    });

    test('leaves currentType unchanged when the place has no category yet', () {
      final model = buildModel();

      model.selectExistingPlace(
        const Place(
          id: 'place-1',
          name: 'New Place',
          latitude: 1.35,
          longitude: 103.82,
        ),
      );

      expect(model.currentType, PinType.restaurant);
    });
  });

  group('selectSuggestion', () {
    test('pre-fills currentType when the place already exists', () async {
      final pins = FakePinService(
        findPlaceByProviderResult: const Place(
          id: 'place-1',
          name: 'Riverside Bar',
          latitude: 1.36,
          longitude: 103.83,
          category: '🍹',
        ),
      );
      final model = buildModel(pins: pins);

      await model.selectSuggestion(
        const NearbyPlace(
          placeId: 'google-place-1',
          name: 'Riverside Bar',
          latitude: 1.36,
          longitude: 103.83,
        ),
      );

      expect(model.currentType, PinType.drinks);
      expect(pins.lastProvider, 'google');
      expect(pins.lastProviderPlaceId, 'google-place-1');
    });

    test('leaves currentType unchanged when the place does not exist yet', () async {
      final pins = FakePinService(findPlaceByProviderResult: null);
      final model = buildModel(pins: pins);

      await model.selectSuggestion(
        const NearbyPlace(
          placeId: 'google-place-1',
          name: 'New Spot',
          latitude: 1.36,
          longitude: 103.83,
        ),
      );

      expect(model.currentType, PinType.restaurant);
    });

    test('leaves currentType unchanged and does not throw when the lookup fails', () async {
      final pins = FakePinService(throwOnFindPlaceByProvider: true);
      final model = buildModel(pins: pins);

      await model.selectSuggestion(
        const NearbyPlace(
          placeId: 'google-place-1',
          name: 'New Spot',
          latitude: 1.36,
          longitude: 103.83,
        ),
      );

      expect(model.currentType, PinType.restaurant);
    });
  });
}
