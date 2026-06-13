import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:jio_leh/models/pinned_location.dart'; 

/// This class is responsible for rendering the pinned locations on the map. 
/// It manages the state of the pins and handles the logic for displaying them without overlap.
/// 
/// [map] is the MapboxMap instance that this class will interact with to render the pins.
class MapPins {

  MapPins(this._map, {
    required this.onPinTapped,
  });
  final void Function(PinnedLocation location) onPinTapped;

  // No need the nullable type as we definitely gonna pass in from constructor
  final MapboxMap _map;

  // Cache for pin images to avoid redundant conversions
  // 
  // Uint8List is the type for raw bytes of the image,
  // which is what Mapbox needs for pin icons
  final Map<String, Uint8List> _emojiImageCache = {};

  // Mapbox Manager for map pins
  PointAnnotationManager? _pinsManager;

  final Map<String, PinnedLocation> _locationsByAnnotationId = {};

  Future<void> render(List<PinnedLocation> locations) async {


    if (_pinsManager == null) {
      _pinsManager = await _map.annotations.createPointAnnotationManager();

      _pinsManager!.tapEvents(onTap: (annotation) {
        final location = _locationsByAnnotationId[annotation.id];

        if(location != null) {
          onPinTapped(location);
        }
      },
      );
    }

    await _pinsManager!.deleteAll();
    _locationsByAnnotationId.clear();


    

    // Keeps track of pins alr shown on map
    final renderedLocations = <PinnedLocation>[]; 

    // Checks if this pin is close to another pin already drawn
    for (final location in locations) {
      final alreadyRenderedNearby = renderedLocations.any(
        (renderedLocation) => _isNearbyLocation(location, renderedLocation),
      );

      // If pins are nearby, skip pinning so no overlapping of names
      if (alreadyRenderedNearby) continue;

      // Else, remember it and draw it
      renderedLocations.add(location);
      final emojiImage = await _emojiImageFor(location.emoji);
      final name = location.name.trim();

      final annotation = await _pinsManager!.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(location.longitude, location.latitude),
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
      _locationsByAnnotationId[annotation.id] = location;
    }
  }

  /// Helper method to determine if two locations are nearby (within 20 meters).
  /// 
  /// Returns true if the absolute difference in both latitude and longitude
  /// is less than the defined tolerance.
  bool _isNearbyLocation(
    PinnedLocation firstLocation,
    PinnedLocation secondLocation,
  ) {
    const tolerance = 0.0002; // loc within 20m is the "same" place

    final latitudeDifference =
        (firstLocation.latitude - secondLocation.latitude).abs();

    final longitudeDifference =
        (firstLocation.longitude - secondLocation.longitude).abs();

    return latitudeDifference < tolerance && longitudeDifference < tolerance;
  }

  /// Helper method that converts an emoji character into a Uint8List image that can be used
  /// as a pin icon on the map. It uses a cache to avoid redundant conversions for the same emoji.
  /// 
  /// Returns a Uint8List representing the PNG image of the emoji.
  Future<Uint8List> _emojiImageFor(String emoji) async {
    final cachedImage = _emojiImageCache[emoji];

    if (cachedImage != null) {
      return cachedImage;
    }

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    // emoji size. change fontSize to make bigger/smaller
    const imageSize = 128.0;
    const fontSize = 92.0;

    // draw the emoji like a text
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

    // paints emoji onto invisible canvas
    textPainter.paint(canvas, offset);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      // the canvas turn into an image
      imageSize.toInt(),
      imageSize.toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    final emojiImage = byteData!.buffer.asUint8List();
    // converts image into the format Mapbox needs
    _emojiImageCache[emoji] = emojiImage;

    return emojiImage;
  }
}
