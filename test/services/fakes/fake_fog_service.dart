import 'package:jio_leh/pages/map/models/fog_tile.dart';
import 'package:jio_leh/services/fog_service.dart';

/// A pretend FogService for tests. No network - you set the fields from your
/// test to control what each method returns.
class FakeFogService extends FogService {
  FakeFogService({
    this.tiles = const [],
    this.throwOnSave = false,
  });

  List<FogTile> tiles;
  bool throwOnSave;
  Object? loadError;

  int saveTilesCalls = 0;
  int loadTilesInBoundsCalls = 0;

  Set<FogTile>? lastSavedTiles;
  double? lastWest;
  double? lastSouth;
  double? lastEast;
  double? lastNorth;

  @override
  Future<void> saveTiles(Set<FogTile> tiles) async {
    saveTilesCalls++;
    lastSavedTiles = {...tiles};

    if (throwOnSave) {
      throw StateError('FakeFogService save failed');
    }
  }

  @override
  Future<List<FogTile>> loadTilesInBounds({
    required double west,
    required double south,
    required double east,
    required double north,
  }) async {
    loadTilesInBoundsCalls++;

    final error = loadError;
    if (error != null) throw error;

    lastWest = west;
    lastSouth = south;
    lastEast = east;
    lastNorth = north;
    return tiles;
  }
}
