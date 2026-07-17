import 'package:jio_leh/pages/map/models/fog_tile.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/fog_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFogService extends FogService{
  SupabaseFogService({required SupabaseClient client, required this.auth})
    : _supabase = client;
  
  final AuthService auth;
  final SupabaseClient _supabase;

  static const _table = 'explored_tiles';

  @override
  Future<void> saveTiles(Set<FogTile> tiles) async {
    if (tiles.isEmpty) return;

    final userId = auth.getCurrentUserId();
    final rows = [
      for (final tile in tiles)
        {'user_id': userId, 'tile_x': tile.x, 'tile_y': tile.y},
    ];

    await _supabase.from(_table).upsert(
      rows,
      onConflict: 'user_id,tile_x,tile_y',
      ignoreDuplicates: true,
    );
  }

  @override
  Future<List<FogTile>> loadTilesInBounds({
    required double west,
    required double south,
    required double east,
    required double north,
  }) async {
    final southWest = FogTile.fromLatLng(south, west);
    final northEast = FogTile.fromLatLng(north, east);

    final rows = await _supabase
        .from(_table)
        .select('tile_x, tile_y')
        .gte('tile_x', southWest.x)
        .lte('tile_x', northEast.x)
        .gte('tile_y', southWest.y)
        .lte('tile_y', northEast.y);

    return rows.map(FogTile.fromMap).toList();
  }
}