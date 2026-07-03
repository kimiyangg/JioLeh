import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/nearby_place.dart';
import 'package:jio_leh/pages/map/location_customize_page.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';

import '../../services/fakes/fake_place_service.dart';

void main() {
  Widget wrap(Widget child, {required FakePlaceService places}) {
    return MaterialApp(
      home: ServiceProvider(places: places, child: child),
    );
  }

  group('LocationCustomizePage nearby-place fetch', () {
    testWidgets('fetches nearby places using the given coordinates', (
      tester,
    ) async {
      final places = FakePlaceService();

      await tester.pumpWidget(
        wrap(
          const LocationCustomizePage(
            selectedType: PinType.restaurant,
            latitude: 1.35,
            longitude: 103.82,
          ),
          places: places,
        ),
      );
      await tester.pump();

      expect(places.getNearbyPlacesCalls, 1);
      expect(places.lastLatitude, 1.35);
      expect(places.lastLongitude, 103.82);
    });

    testWidgets('does not fetch when read-only', (tester) async {
      final places = FakePlaceService();

      await tester.pumpWidget(
        wrap(
          const LocationCustomizePage(
            selectedType: PinType.restaurant,
            isReadOnly: true,
            latitude: 1.35,
            longitude: 103.82,
          ),
          places: places,
        ),
      );
      await tester.pump();

      expect(places.getNearbyPlacesCalls, 0);
    });

    testWidgets('does not fetch when coordinates are not provided', (
      tester,
    ) async {
      final places = FakePlaceService();

      await tester.pumpWidget(
        wrap(
          const LocationCustomizePage(selectedType: PinType.restaurant),
          places: places,
        ),
      );
      await tester.pump();

      expect(places.getNearbyPlacesCalls, 0);
    });
  });

  group('LocationCustomizePage nearby-place suggestions UI', () {
    testWidgets('renders fetched suggestions and fills the field on tap', (
      tester,
    ) async {
      final places = FakePlaceService(
        places: const [
          NearbyPlace(
            placeId: 'place-1',
            name: 'Kopi Place',
            latitude: 1.35,
            longitude: 103.82,
          ),
          NearbyPlace(
            placeId: 'place-2',
            name: 'Riverside Park',
            latitude: 1.36,
            longitude: 103.83,
          ),
        ],
      );

      await tester.pumpWidget(
        wrap(
          const LocationCustomizePage(
            selectedType: PinType.restaurant,
            latitude: 1.35,
            longitude: 103.82,
          ),
          places: places,
        ),
      );
      await tester.pump();

      expect(find.text('Kopi Place'), findsOneWidget);
      expect(find.text('Riverside Park'), findsOneWidget);

      await tester.tap(find.text('Kopi Place'));
      await tester.pump();

      final formalNameField = tester.widget<TextField>(
        find.byType(TextField).first,
      );
      expect(formalNameField.controller!.text, 'Kopi Place');
      expect(find.text('Riverside Park'), findsNothing);
    });

    testWidgets('renders nothing extra when there are no suggestions', (
      tester,
    ) async {
      final places = FakePlaceService();

      await tester.pumpWidget(
        wrap(
          const LocationCustomizePage(
            selectedType: PinType.restaurant,
            latitude: 1.35,
            longitude: 103.82,
          ),
          places: places,
        ),
      );
      await tester.pump();

      expect(find.text("Can't find it? Type it in below."), findsNothing);
    });
  });
}
