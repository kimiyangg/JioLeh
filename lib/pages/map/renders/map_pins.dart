import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/models/user_pin.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// This class renders places on the map and links marker taps back to a place.
class MapPins {
  MapPins(this._map, {required this.onPinTapped});

  final void Function(Place place) onPinTapped;
  final MapboxMap _map;

  final Map<String, Uint8List> _emojiImageCache = {};
  final Map<String, Place> _placesByAnnotationId = {};

  PointAnnotationManager? _pinsManager;

  Future<void> render(List<Place> places) async {
    if (_pinsManager == null) {
      _pinsManager = await _map.annotations.createPointAnnotationManager();

      _pinsManager!.tapEvents(
        onTap: (annotation) {
          final place = _placesByAnnotationId[annotation.id];

          if (place != null) {
            onPinTapped(place);
          }
        },
      );
    }

    await _pinsManager!.deleteAll();
    _placesByAnnotationId.clear();

    final renderedPlaces = <Place>[];

    for (final place in places) {
      final alreadyRenderedNearby = renderedPlaces.any(
        (renderedPlace) => _isNearbyPlace(place, renderedPlace),
      );

      if (alreadyRenderedNearby) continue;

      renderedPlaces.add(place);

      final pin = _primaryPinFor(place);
      final emojiImage = await _emojiImageFor(pin?.emoji ?? '\u{1F4CD}');
      final name = _displayNameFor(place, pin);

      final annotation = await _pinsManager!.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(place.longitude, place.latitude),
          ),
          image: emojiImage,
          iconSize: 0.55,
          iconAnchor: IconAnchor.BOTTOM,
          textField: name.isEmpty ? null : name,
          textSize: 15,
          textOffset: [0, 0.8],
          textAnchor: TextAnchor.TOP,
          textColor: Colors.black.toARGB32(),
          textHaloColor: Colors.white.toARGB32(),
          textHaloWidth: 2,
        ),
      );

      _placesByAnnotationId[annotation.id] = place;
    }
  }

  UserPin? _primaryPinFor(Place place) {
    return place.pins.isEmpty ? null : place.pins.first;
  }

  String _displayNameFor(Place place, UserPin? pin) {
    final customName = pin?.customName?.trim();

    if (customName != null && customName.isNotEmpty) {
      return customName;
    }

    return place.name.trim();
  }

  bool _isNearbyPlace(Place firstPlace, Place secondPlace) {
    const tolerance = 0.0002; // loc within 20m is the "same" place

    final latitudeDifference = (firstPlace.latitude - secondPlace.latitude)
        .abs();
    final longitudeDifference = (firstPlace.longitude - secondPlace.longitude)
        .abs();

    return latitudeDifference < tolerance && longitudeDifference < tolerance;
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
