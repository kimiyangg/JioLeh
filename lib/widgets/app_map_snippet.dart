import 'package:flutter/material.dart';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:jio_leh/config/map_env.dart';
import 'package:jio_leh/theme.dart';

// A non-interactive mini-map centred on a coordinate, with an optional emoji overlaid as the marker. Holds no state; the parent passes the coordinate and emoji in.
class AppMapSnippet extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String emoji;
  final double zoom;

  const AppMapSnippet({
    super.key,
    required this.latitude,
    required this.longitude,
    this.emoji = '',
    this.zoom = AppMapSnip.zoom,
  });

  // Runs once when the native map is ready: locks all gestures and hides the chrome so the map reads as a static thumbnail.
  Future<void> _onMapCreated(MapboxMap map) async {
    await map.gestures.updateSettings(
      GesturesSettings(
        rotateEnabled: false,
        pinchToZoomEnabled: false,
        scrollEnabled: false,
        pitchEnabled: false,
        doubleTapToZoomInEnabled: false,
        doubleTouchToZoomOutEnabled: false,
        quickZoomEnabled: false,
      ),
    );
    await map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await map.compass.updateSettings(CompassSettings(enabled: false));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.elements),
      child: SizedBox(
        height: AppMapSnip.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MapWidget(
              // The native map only applies the viewport on creation, so a coordinate change must recreate it.
              key: ValueKey('$latitude,$longitude'),
              styleUri: MapEnv.mapboxStyleUri,
              viewport: CameraViewportState(
                center: Point(coordinates: Position(longitude, latitude)),
                zoom: zoom,
              ),
              onMapCreated: _onMapCreated,
            ),
            if (emoji.isNotEmpty)
              Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: AppMapSnip.emojiSize),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
