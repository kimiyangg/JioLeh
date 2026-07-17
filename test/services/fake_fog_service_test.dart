import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/pages/map/models/fog_tile.dart';
import 'package:jio_leh/services/fog_service.dart';

import 'fakes/fake_fog_service.dart';

void main() {
  test('FakeFogService can stand in for FogService', () async {
    const returned = FogTile(5, 8);
    final service = FakeFogService(tiles: const [returned]);
    final FogService contract = service;

    await contract.saveTiles({const FogTile(1, 2)});
    final loaded = await contract.loadTilesInBounds(
      west: 103.8,
      south: 1.2,
      east: 103.9,
      north: 1.3,
    );

    expect(service.saveTilesCalls, 1);
    expect(service.lastSavedTiles, {const FogTile(1, 2)});
    expect(service.loadTilesInBoundsCalls, 1);
    expect(service.lastWest, 103.8);
    expect(service.lastSouth, 1.2);
    expect(service.lastEast, 103.9);
    expect(service.lastNorth, 1.3);
    expect(loaded, const [returned]);
  });

  test('FakeFogService throwOnSave surfaces an error to the caller', () async {
    final service = FakeFogService(throwOnSave: true);
    final FogService contract = service;

    expect(
      () => contract.saveTiles({const FogTile(1, 2)}),
      throwsStateError,
    );
  });
}
