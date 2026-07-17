import 'package:jio_leh/pages/map/models/fog_tile.dart';

/// The contract for reading and recording the grid cells a user has explored.
/// The whole app depends on this, so the real Supabase service can be swapped
/// for a fake in tests.
abstract class FogService {
  /// Records the given [tiles] as explored for the current user. Callers pass a
  /// de-duplicated set; already-explored tiles are ignored, not re-inserted.
  Future<void> saveTiles(Set<FogTile> tiles);

  /// Loads the current user's explored tiles whose coordinates fall inside the
  /// given bounding box.
  Future<List<FogTile>> loadTilesInBounds({
    required double west,
    required double south,
    required double east,
    required double north,
  });
}
