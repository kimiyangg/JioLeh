import 'dart:async';

import 'package:geolocator/geolocator.dart' as geo;
class LocationServices {
  // Service class to handle all location-related functionality, 
  // including permission checks, fetching current location, and real-time tracking
  StreamSubscription<geo.Position>? _positionStream;

  Future<bool> ensureLocationPermission() async {
    // Checks if location services are enabled and requests permission if not already granted
    // Current code falls back to default location if permission is denied
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return false;
    }

    geo.LocationPermission permission =
        await geo.Geolocator.checkPermission();

    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }

    if (permission == geo.LocationPermission.deniedForever) {
      await geo.Geolocator.openAppSettings();
      return false;
    }

    if (permission == geo.LocationPermission.denied) {
      return false;
    }

    return true;
  }

  Future<geo.Position> getCurrentLocation() async {
    // Fetches the user's current location
    await ensureLocationPermission();
    return geo.Geolocator.getCurrentPosition(
      locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
      )
    );
  }

  Future<bool> startLocationTracking({
    required void Function(geo.Position position) onLocationUpdate,
    void Function(Object error)? onError,
  }) async {
    // Starts tracking the user's location in real-time and calls provided callback on update
    if (_positionStream != null) {
      return false;
    }
    final hasPermission = await ensureLocationPermission();
    if (!hasPermission) {
      return false;
    }
    _positionStream = geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 1, // Only receive updates when the user has moved at least 1 meter
      ),
    ).listen(
      onLocationUpdate,
      onError: onError,
    );
    return true;
  }

  Future<void> dispose() async {
    // Cancels the location tracking stream subscription to free up resources
    await _positionStream?.cancel();
    _positionStream = null;
  }
}