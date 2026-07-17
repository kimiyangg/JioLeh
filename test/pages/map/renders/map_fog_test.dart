import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/pages/map/models/fog_tile.dart';
import 'package:jio_leh/pages/map/renders/map_fog.dart';

// The polygon's rings: coordinates[0] is the outer ring, [1..] are holes.
List<dynamic> _rings(String geojson) {
  final decoded = json.decode(geojson) as Map<String, dynamic>;
  final features = decoded['features'] as List;
  final geometry = (features.single as Map)['geometry'] as Map;
  return geometry['coordinates'] as List;
}

// Shoelace signed area: > 0 is counter-clockwise, < 0 is clockwise.
double _signedArea(List<dynamic> ring) {
  var sum = 0.0;
  for (var i = 0; i < ring.length - 1; i++) {
    final a = ring[i] as List;
    final b = ring[i + 1] as List;
    sum += (a[0] as num) * (b[1] as num) - (b[0] as num) * (a[1] as num);
  }
  return sum / 2;
}

void main() {
  group('fogFeatureCollection', () {
    test('empty tile set is one polygon with only the world ring', () {
      final rings = _rings(fogFeatureCollection({}));

      expect(rings, hasLength(1));
    });

    test('one tile adds one hole at that tile\'s corners', () {
      const tile = FogTile(1, 1);
      final rings = _rings(fogFeatureCollection({tile}));

      expect(rings, hasLength(2));

      final hole = rings[1] as List;
      final xs = hole.map((p) => (p as List)[0] as double).toSet();
      final ys = hole.map((p) => (p as List)[1] as double).toSet();

      expect(xs, {tile.west, tile.east});
      expect(ys, {tile.south, tile.north});
    });

    test('outer ring is counter-clockwise and the hole is clockwise', () {
      final rings = _rings(fogFeatureCollection({const FogTile(1, 1)}));

      expect(_signedArea(rings[0] as List), greaterThan(0));
      expect(_signedArea(rings[1] as List), lessThan(0));
    });

    test('N tiles produce N holes', () {
      final tiles = {
        const FogTile(1, 1),
        const FogTile(2, 2),
        const FogTile(3, 3),
      };
      final rings = _rings(fogFeatureCollection(tiles));

      expect(rings, hasLength(1 + tiles.length));
    });
  });
}
