import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/models/nearby_place.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/pages/map/location_form_page.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';

import '../../services/fakes/fake_pin_service.dart';
import '../../services/fakes/fake_place_service.dart';

void main() {
  Widget wrap(
    Widget child, {
    required FakePlaceService places,
    FakePinService? pins,
  }) {
    return MaterialApp(
      home: ServiceProvider(
        places: places,
        pins: pins ?? FakePinService(),
        child: child,
      ),
    );
  }

  group('LocationFormPage Find nearby button', () {
    testWidgets('does not render when read-only', (tester) async {
      final places = FakePlaceService();

      await tester.pumpWidget(
        wrap(
          const LocationFormPage(
            selectedType: PinType.restaurant,
            isReadOnly: true,
            latitude: 1.35,
            longitude: 103.82,
          ),
          places: places,
        ),
      );
      await tester.pump();

      expect(find.text('Find nearby'), findsNothing);
    });

    testWidgets('does not render when coordinates are not provided', (
      tester,
    ) async {
      final places = FakePlaceService();

      await tester.pumpWidget(
        wrap(
          const LocationFormPage(selectedType: PinType.restaurant),
          places: places,
        ),
      );
      await tester.pump();

      expect(find.text('Find nearby'), findsNothing);
    });

    testWidgets('fetches and opens a sheet listing every result on tap', (
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
          const LocationFormPage(
            selectedType: PinType.restaurant,
            latitude: 1.35,
            longitude: 103.82,
          ),
          places: places,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Find nearby'));
      await tester.pumpAndSettle();

      expect(places.getNearbyPlacesCalls, 1);
      expect(places.lastLatitude, 1.35);
      expect(places.lastLongitude, 103.82);
      expect(find.text('Kopi Place'), findsOneWidget);
      expect(find.text('Riverside Park'), findsOneWidget);
    });

    testWidgets('tapping a place in the sheet shows the chosen place card', (
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
        ],
      );

      await tester.pumpWidget(
        wrap(
          const LocationFormPage(
            selectedType: PinType.restaurant,
            latitude: 1.35,
            longitude: 103.82,
          ),
          places: places,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Find nearby'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kopi Place'));
      await tester.pumpAndSettle();
      expect(find.text('Kopi Place'), findsOneWidget);
      expect(find.text('From Google'), findsOneWidget);
    });

    testWidgets('does not re-fetch on a second tap', (tester) async {
      final places = FakePlaceService(
        places: const [
          NearbyPlace(
            placeId: 'place-1',
            name: 'Kopi Place',
            latitude: 1.35,
            longitude: 103.82,
          ),
        ],
      );

      await tester.pumpWidget(
        wrap(
          const LocationFormPage(
            selectedType: PinType.restaurant,
            latitude: 1.35,
            longitude: 103.82,
          ),
          places: places,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Find nearby'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kopi Place'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Find nearby'));
      await tester.pumpAndSettle();

      expect(places.getNearbyPlacesCalls, 1);
      expect(find.text('Kopi Place'), findsOneWidget);
    });

    testWidgets('shows a message when there are no nearby places', (
      tester,
    ) async {
      final places = FakePlaceService();

      await tester.pumpWidget(
        wrap(
          const LocationFormPage(
            selectedType: PinType.restaurant,
            latitude: 1.35,
            longitude: 103.82,
          ),
          places: places,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Find nearby'));
      await tester.pumpAndSettle();

      expect(find.text('No nearby places found.'), findsOneWidget);
    });
  });

  group('LocationFormPage Popular around button', () {
    testWidgets('fetches within 0.5km and opens a sheet listing every result', (
      tester,
    ) async {
      final pins = FakePinService(
        places: const [
          Place(
            id: 'place-1',
            name: 'Old Kopi Place',
            latitude: 1.35,
            longitude: 103.82,
          ),
        ],
      );

      await tester.pumpWidget(
        wrap(
          const LocationFormPage(
            selectedType: PinType.restaurant,
            latitude: 1.35,
            longitude: 103.82,
          ),
          places: FakePlaceService(),
          pins: pins,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Popular around'));
      await tester.pumpAndSettle();

      expect(pins.loadPlacesNearLocationCalls, 1);
      expect(pins.lastLatitude, 1.35);
      expect(pins.lastLongitude, 103.82);
      expect(pins.lastRadiusKm, 0.5);
      expect(find.text('Old Kopi Place'), findsOneWidget);
    });

    testWidgets('tapping an existing place shows the chosen place card', (
      tester,
    ) async {
      final pins = FakePinService(
        places: const [
          Place(
            id: 'place-1',
            name: 'Old Kopi Place',
            latitude: 1.35,
            longitude: 103.82,
          ),
        ],
      );

      await tester.pumpWidget(
        wrap(
          const LocationFormPage(
            selectedType: PinType.restaurant,
            latitude: 1.35,
            longitude: 103.82,
          ),
          places: FakePlaceService(),
          pins: pins,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Popular around'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Old Kopi Place'));
      await tester.pumpAndSettle();
      expect(find.text('Old Kopi Place'), findsOneWidget);
      expect(find.text('Linked from an existing pin'), findsOneWidget);
    });

    testWidgets('shows a message when there are no existing places nearby', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const LocationFormPage(
            selectedType: PinType.restaurant,
            latitude: 1.35,
            longitude: 103.82,
          ),
          places: FakePlaceService(),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Popular around'));
      await tester.pumpAndSettle();

      expect(find.text('No existing places found nearby.'), findsOneWidget);
    });
  });
}
