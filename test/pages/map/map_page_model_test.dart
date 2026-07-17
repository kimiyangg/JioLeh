import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/pages/map/map_page_model.dart';
import 'package:jio_leh/pages/map/models/fog_tile.dart';
import 'package:jio_leh/services/geocoding_service.dart';
import 'package:jio_leh/services/location_service.dart';

import '../../services/fakes/fake_fog_service.dart';
import '../../services/fakes/fake_pin_service.dart';

void main() {
  // The real LocationService/GeocodingService are constructed but never
  // started, so no platform channels fire. Only the fog path is exercised.
  MapPageModel makeModel(FakeFogService fog) {
    return MapPageModel(
      pins: FakePinService(),
      location: LocationService(),
      geocoding: GeocodingService(),
      fog: fog,
    );
  }

  group('MapPageModel.reloadFogInBounds', () {
    test('passes bounds through and replaces exploredTiles', () async {
      final fog = FakeFogService(tiles: const [FogTile(1, 2), FogTile(3, 4)]);
      final model = makeModel(fog);

      await model.reloadFogInBounds(
        west: 103.8,
        south: 1.2,
        east: 103.9,
        north: 1.3,
      );

      expect(fog.lastWest, 103.8);
      expect(fog.lastSouth, 1.2);
      expect(fog.lastEast, 103.9);
      expect(fog.lastNorth, 1.3);
      expect(model.exploredTiles, {const FogTile(1, 2), const FogTile(3, 4)});
    });

    test('a second load replaces the cache instead of accumulating', () async {
      final fog = FakeFogService(tiles: const [FogTile(1, 1)]);
      final model = makeModel(fog);
      await model.reloadFogInBounds(west: 0, south: 0, east: 1, north: 1);

      fog.tiles = const [FogTile(9, 9)];
      await model.reloadFogInBounds(west: 9, south: 9, east: 10, north: 10);

      expect(model.exploredTiles, {const FogTile(9, 9)});
    });

    test('swallows a load error and leaves the cache unchanged', () async {
      final fog = FakeFogService(tiles: const [FogTile(1, 1)]);
      final model = makeModel(fog);
      await model.reloadFogInBounds(west: 0, south: 0, east: 1, north: 1);

      fog.loadError = Exception('offline');
      await model.reloadFogInBounds(west: 9, south: 9, east: 10, north: 10);

      expect(model.exploredTiles, {const FogTile(1, 1)});
    });

    test('swaps in a new set object when content changes', () async {
      final fog = FakeFogService(tiles: const [FogTile(1, 1)]);
      final model = makeModel(fog);
      final before = model.exploredTiles;

      await model.reloadFogInBounds(west: 0, south: 0, east: 1, north: 1);

      expect(identical(before, model.exploredTiles), isFalse);
    });
  });

  group('MapPageModel.toggleFog', () {
    test('flips fogEnabled and notifies once per call', () {
      final model = makeModel(FakeFogService());
      var notifications = 0;
      model.addListener(() => notifications++);

      model.toggleFog();
      expect(model.fogEnabled, isFalse);
      expect(notifications, 1);

      model.toggleFog();
      expect(model.fogEnabled, isTrue);
      expect(notifications, 2);
    });
  });
}
