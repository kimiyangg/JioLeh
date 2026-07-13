import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/models/user_inserted_pin.dart';
import 'package:jio_leh/services/geocoding_service.dart';
import 'package:jio_leh/services/location_service.dart';
import 'package:jio_leh/services/pin_service.dart';

/// Presentation state and logic for [MapPage].
///
/// Owns the user's location, nearby places, and pin saving. UI-only effects
/// such as the map render, camera, and error dialog stay in the widget.
/// Call [start] once after construction to begin location tracking.
class MapPageModel extends ChangeNotifier {
  MapPageModel({
    required this.pins,
    required this.location,
    required this.geocoding,
  });

  final PinService pins;
  final LocationService location;
  final GeocodingService geocoding;
  double? _pendingLatitude;
  double? _pendingLongitude;


  geo.Position? _currentPosition;
  bool _isLoadingLocation = true;
  String _locationName = 'Fetching location...';
  List<Place> _places = [];
  bool _disposed = false;

  geo.Position? get currentPosition => _currentPosition;
  bool get isLoadingLocation => _isLoadingLocation;
  String get locationName => _locationName;
  List<Place> get places => _places;
  double? get pendingLatitude => _pendingLatitude;
  double? get pendingLongitude => _pendingLongitude;

  Future<void> start() async {
    try {
      final position = await location.getCurrentLocation();
      if (_disposed) return;

      _currentPosition = position;
      _isLoadingLocation = false;
      notifyListeners();

      _updateLocationName(position);
      await reloadPlaces();
      await location.startLocationTracking(onLocationUpdate: _onLocationUpdate);
    } catch (_) {
      if (_disposed) return;
      _isLoadingLocation = false;
      notifyListeners();
      rethrow;
    }
  }

  void _onLocationUpdate(geo.Position position) {
    if (_disposed) return;
    _currentPosition = position;
    notifyListeners();
    _updateLocationName(position);
  }

  Future<void> _updateLocationName(geo.Position position) async {
    final name = await geocoding.fetchAreaName(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    if (_disposed) return;
    _locationName = name;
    notifyListeners();
  }

  Future<void> reloadPlaces() async {
    final position = _currentPosition;
    if (position == null) return;

    final places = await pins.loadPlacesNearLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    if (_disposed) return;
    _places = places;
    notifyListeners();
  }

  Future<void> reloadPlacesInBounds({
    required double west,
    required double south,
    required double east,
    required double north,
  }) async {
    final places = await pins.loadPlacesInBounds(
      west: west,
      south: south,
      east: east,
      north: north,
    );
    if (_disposed) return;
    _places = places;
    notifyListeners();
  }

  Future<void> savePin(
    UserInsertedPin pin,
    List<XFile> photos, {
    String? existingPlaceId,
  }) async {
    await pins.saveUserInsertedPin(
      pin,
      photos,
      existingPlaceId: existingPlaceId,
    );
    await reloadPlaces();
  }

  Future<List<String>> photoUrls(List<String> paths) {
    return pins.createPhotoUrls(paths);
  }

  @override
  void dispose() {
    _disposed = true;
    location.dispose();
    super.dispose();
  }

  /// Asks the map to move its camera to the given location the next time
  /// it is visible.
  void requestCameraMove(double latitude, double longitude) {
    _pendingLatitude = latitude;
    _pendingLongitude = longitude;
    notifyListeners();
  }

  /// Called by MapPage once it has handled the pending camera move.
  void clearPendingCameraMove() {
    _pendingLatitude = null;
    _pendingLongitude = null;
  }
}
