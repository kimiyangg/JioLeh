import 'dart:convert';

import 'package:jio_leh/pages/map/models/fog_tile.dart';
import 'package:jio_leh/theme.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Renders unexplored area as one world-covering fill with a hole punched out
/// for every explored tile, so Mapbox owns all of the camera/projection math.
class MapFog {
  MapFog(this._map);

  final MapboxMap _map;

  static const _sourceId = 'fog_source';
  static const _layerId = 'fog_layer';

  GeoJsonSource? _source;
  // Guards the one-time source/layer creation so overlapping renders (a GPS
  // fix landing mid-await) share a single addSource instead of double-adding.
  Future<void>? _setup;

  Future<void> render(Set<FogTile> tiles) async {
    final data = fogFeatureCollection(tiles);

    try {
      await (_setup ??= _addLayers(data));
    } catch (_) {
      _setup = null; // Let a later render retry the one-time setup.
      return;
    }

    await _source!.updateGeoJSON(data);
  }

  Future<void> _addLayers(String initialData) async {
    final source = GeoJsonSource(id: _sourceId, data: initialData);
    await _map.style.addSource(source);
    _source = source;

    await _map.style.addLayer(
      FillLayer(
        id: _layerId,
        sourceId: _sourceId,
        fillColor: AppColors.fogFill.toARGB32(),
        fillOpacity: 0.55,
      ),
    );
  }

  Future<void> setVisible(bool visible) async {
    final setup = _setup;
    if (setup == null) return; // Nothing rendered yet, no layer to toggle.
    await setup;

    await _map.style.setStyleLayerProperty(
      _layerId,
      'visibility',
      visible ? 'visible' : 'none',
    );
  }
}

/// Builds the fog GeoJSON: one polygon whose outer ring covers the world
/// (counter-clockwise) and whose holes are the explored tiles (clockwise),
/// per the RFC 7946 winding rule. Pure so the geometry can be unit tested.
String fogFeatureCollection(Set<FogTile> tiles) {
  const world = [
    [-180.0, -85.0],
    [180.0, -85.0],
    [180.0, 85.0],
    [-180.0, 85.0],
    [-180.0, -85.0],
  ];

  final holes = [
    for (final tile in tiles)
      [
        [tile.west, tile.south],
        [tile.west, tile.north],
        [tile.east, tile.north],
        [tile.east, tile.south],
        [tile.west, tile.south],
      ],
  ];

  return json.encode({
    'type': 'FeatureCollection',
    'features': [
      {
        'type': 'Feature',
        'geometry': {
          'type': 'Polygon',
          'coordinates': [world, ...holes],
        },
        'properties': <String, Object?>{},
      },
    ],
  });
}
