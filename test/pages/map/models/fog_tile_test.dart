import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/pages/map/models/fog_tile.dart';

void main() {
  group('FogTile.fromLatLng', () {
    test('maps positive coordinates to floored tile indices', () {
      final tile = FogTile.fromLatLng(1.29, 103.85);

      expect(tile.x, (103.85 / FogTile.tileSizeDeg).floor());
      expect(tile.y, (1.29 / FogTile.tileSizeDeg).floor());
    });

    test('floors negative coordinates toward the lower tile', () {
      final tile = FogTile.fromLatLng(-0.0001, -0.0001);

      expect(tile.x, -1);
      expect(tile.y, -1);
    });

    test('assigns a coordinate exactly on a grid line to the upper tile', () {
      final tile = FogTile.fromLatLng(FogTile.tileSizeDeg, FogTile.tileSizeDeg);

      expect(tile.x, 1);
      expect(tile.y, 1);
    });
  });

  group('FogTile corners', () {
    test('are the inverse of fromLatLng (round-trips to the same tile)', () {
      const tile = FogTile(461564, 5734);

      expect(FogTile.fromLatLng(tile.south, tile.west), tile);
    });

    test('east and north are exactly one tile past west and south', () {
      const tile = FogTile(10, 20);

      expect(tile.east, tile.west + FogTile.tileSizeDeg);
      expect(tile.north, tile.south + FogTile.tileSizeDeg);
    });
  });

  group('FogTile.neighbours', () {
    test('returns exactly nine tiles', () {
      expect(const FogTile(0, 0).neighbours(), hasLength(9));
    });

    test('includes the centre tile itself', () {
      expect(const FogTile(5, 8).neighbours(), contains(const FogTile(5, 8)));
    });
  });

  group('FogTile equality', () {
    test('tiles with the same coordinates collapse in a Set', () {
      final tiles = [const FogTile(5, 8), const FogTile(5, 8)];

      expect(tiles.toSet(), hasLength(1));
    });

    test('differ when only x differs', () {
      expect(const FogTile(5, 8), isNot(const FogTile(6, 8)));
    });

    test('differ when only y differs', () {
      expect(const FogTile(5, 8), isNot(const FogTile(5, 9)));
    });
  });
}
