import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/theme.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// This class renders places on the map and links marker taps back to a place.
class MapPins {
  MapPins(this._map, {required this.onPinTapped});

  final void Function(Place place) onPinTapped;
  final MapboxMap _map;

  static const _sourceId = 'user_pins_source';
  static const _pinsLayerId = 'user_pins_layer';
  static const _clusterCircleLayerId = 'user_pins_cluster_circles';
  static const _clusterCountLayerId = 'user_pins_cluster_count';

  final Map<String, Uint8List> _emojiImageCache = {};
  final Set<String> _registeredIcons = {};
  Map<String, Place> _placesByPlaceId = {};

  GeoJsonSource? _pinsSource;

  Future<void> render(List<Place> places) async {
    await _ensureIconsRegistered(places);

    _placesByPlaceId = {
      for (final place in places)
        if (place.id != null) place.id!: place,
    };

    final data = _featureCollectionFor(places);

    if (_pinsSource == null) {
      await _setUpLayers(data);
    } else {
      await _pinsSource!.updateGeoJSON(data);
    }
  }

  Future<void> _setUpLayers(String initialData) async {
    final source = GeoJsonSource(
      id: _sourceId,
      data: initialData,
      cluster: true,
      clusterRadius: 50,
      clusterMaxZoom: 16,
    );
    await _map.style.addSource(source);
    _pinsSource = source;

    await _map.style.addLayer(
      SymbolLayer(
        id: _pinsLayerId,
        sourceId: _sourceId,
        filter: <Object>[
          '!',
          <Object>['has', 'point_count'],
        ],
        iconImageExpression: <Object>['get', 'icon'],
        iconSize: 0.55,
        iconAnchor: IconAnchor.BOTTOM,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
      ),
    );

    await _map.style.addLayer(
      CircleLayer(
        id: _clusterCircleLayerId,
        sourceId: _sourceId,
        filter: <Object>['has', 'point_count'],
        circleColor: AppColors.lightWidgetBackground.toARGB32(),
        circleRadiusExpression: <Object>[
          'step',
          <Object>['get', 'point_count'],
          18.0,
          5,
          24.0,
          15,
          32.0,
        ],
      ),
    );

    await _map.style.addLayer(
      SymbolLayer(
        id: _clusterCountLayerId,
        sourceId: _sourceId,
        filter: <Object>['has', 'point_count'],
        textFieldExpression: <Object>['get', 'point_count_abbreviated'],
        textSize: 14,
        textColor: Colors.white.toARGB32(),
      ),
    );

    _map.setOnMapTapListener(_onMapTapped);
  }

  void _onMapTapped(MapContentGestureContext context) async {
    final results = await _map.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(context.touchPosition),
      RenderedQueryOptions(
        layerIds: [_pinsLayerId, _clusterCircleLayerId],
      ),
    );

    if (results.isEmpty) return;

    final feature = results.first?.queriedFeature.feature;
    final properties = feature?['properties'] as Map?;

    if (properties?['point_count'] != null) {
      await _expandCluster(feature!);
      return;
    }

    final placeId = properties?['place_id'] as String?;
    final place = placeId == null ? null : _placesByPlaceId[placeId];
    if (place != null) {
      onPinTapped(place);
    }
  }

  Future<void> _expandCluster(Map<String?, Object?> feature) async {
    final zoomResult = await _map.getGeoJsonClusterExpansionZoom(
      _sourceId,
      feature,
    );
    final zoom = double.tryParse(zoomResult.value ?? '');
    if (zoom == null) return;

    final geometry = feature['geometry'] as Map?;
    final coordinates = geometry?['coordinates'] as List?;
    if (coordinates == null) return;

    await _map.easeTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            (coordinates[0] as num).toDouble(),
            (coordinates[1] as num).toDouble(),
          ),
        ),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 500),
    );
  }

  String _featureCollectionFor(List<Place> places) {
    final features = [
      for (final place in places)
        if (place.id != null)
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [place.longitude, place.latitude],
            },
            'properties': {
              'place_id': place.id,
              'icon': place.category ?? '\u{1F4CD}',
            },
          },
    ];

    return json.encode({'type': 'FeatureCollection', 'features': features});
  }

  Future<void> _ensureIconsRegistered(List<Place> places) async {
    for (final place in places) {
      final emoji = place.category ?? '\u{1F4CD}';
      if (_registeredIcons.contains(emoji)) continue;

      final bytes = await _emojiImageFor(emoji);
      await _map.style.addStyleImage(
        emoji,
        1.0,
        MbxImage(width: 128, height: 128, data: bytes),
        false,
        [],
        [],
        null,
      );
      _registeredIcons.add(emoji);
    }
  }

  Future<Uint8List> _emojiImageFor(String emoji) async {
    final cachedImage = _emojiImageCache[emoji];

    if (cachedImage != null) {
      return cachedImage;
    }

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    const imageSize = 128.0;
    const fontSize = 92.0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: const TextStyle(fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final offset = Offset(
      (imageSize - textPainter.width) / 2,
      (imageSize - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);

    final picture = recorder.endRecording();
    final image = await picture.toImage(imageSize.toInt(), imageSize.toInt());

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final emojiImage = byteData!.buffer.asUint8List();

    _emojiImageCache[emoji] = emojiImage;

    return emojiImage;
  }
}
