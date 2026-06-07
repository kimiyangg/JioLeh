import 'dart:async';

import 'package:geolocator/geolocator.dart' as geo;

class LocationService {
  // Service class to handle all location-related functionality,
  // including permission checks, fetching current location, and real-time tracking
  StreamSubscription<geo.Position>? _positionStream;

  Future<bool> isLocationEnabled() async {
    // Checks if location services are enabled on the device
    return await geo.Geolocator.isLocationServiceEnabled();
  }

  Future<void> openLocationSettings() async {
    // Opens the device's location settings page
    await geo.Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    // Opens this app's permission settings page
    await geo.Geolocator.openAppSettings();
  }

  Future<void> ensureLocationPermission() async {
    // Throws a typed LocationException when service/permission is unavailable;
    // returns normally when location is usable.
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceOff();
    }

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();

    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }

    if (permission == geo.LocationPermission.deniedForever) {
      throw const LocationBlocked();
    }

    if (permission == geo.LocationPermission.denied) {
      throw const LocationDenied();
    }
  }

  Future<geo.Position> getCurrentLocation() async {
    // Fetches the user's current location.
    // Throws a LocationException if permission/service is unavailable.
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
    // Starts tracking the user's location in real-time and calls provided callback on update.
    // Returns false if tracking is already running. Throws a LocationException if permission/service is unavailable.
    if (_positionStream != null) {
      return false;
    }
    await ensureLocationPermission();
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

class LocationException implements Exception {
  // Base class for all location-related exceptions
  final String message;
  const LocationException(this.message);
  @override
  String toString() => message;
}

class LocationServiceOff extends LocationException {
  // Thrown when location services are disabled on the device-wide settings
  // The user must be directed to location settings to enable it.
  const LocationServiceOff()
      : super('Location services are disabled on this device.');
}

class LocationDenied extends LocationException {
  // Thrown when the user denies location permission but has not permanently blocked it
  // The request location interface can be shown again in this case.
  const LocationDenied() : super('Location permission was denied.');
}

class LocationBlocked extends LocationException {
  // Thrown when the user has permanently blocked location permission (denied forever).
  // The request location interface cannot be shown again,
  // and the user must be directed to app settings to enable it.
  const LocationBlocked()
      : super('Location permission was permanently denied.');
}
