import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/models/user_inserted_pin.dart';
import 'package:jio_leh/pages/map/models/fog_tile.dart';
import 'package:jio_leh/services/fog_service.dart';
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
    required this.fog,
  });

  final PinService pins;
  final LocationService location;
  final GeocodingService geocoding;
  final FogService fog;

  // Flush the pending upload buffer once it reaches this many tiles, or after
  // [_uploadDebounce] of no movement, whichever comes first.
  static const int _uploadBatchSize = 40;
  static const Duration _uploadDebounce = Duration(seconds: 5);

  geo.Position? _currentPosition;
  bool _isLoadingLocation = true;
  String _locationName = 'Fetching location...';
  List<Place> _places = [];
  Set<FogTile> _exploredTiles = {};
  final Set<FogTile> _pendingUpload = {};
  bool _fogEnabled = true;
  Timer? _uploadTimer;
  bool _disposed = false;

  geo.Position? get currentPosition => _currentPosition;
  bool get isLoadingLocation => _isLoadingLocation;
  String get locationName => _locationName;
  List<Place> get places => _places;
  Set<FogTile> get exploredTiles => _exploredTiles;
  bool get fogEnabled => _fogEnabled;

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
    _recordExploration(position);
  }

  // Write path: reveal the 3x3 block around the user, upload it batched.
  void _recordExploration(geo.Position position) {
    final centre = FogTile.fromLatLng(position.latitude, position.longitude);
    final fresh = [
      for (final tile in centre.neighbours())
        if (!_exploredTiles.contains(tile)) tile,
    ];
    if (fresh.isEmpty) return;

    // Optimistic reveal; a new set so identical() change checks see the update.
    _exploredTiles = {..._exploredTiles, ...fresh};
    _pendingUpload.addAll(fresh);
    notifyListeners();
    _scheduleUpload();
  }

  void _scheduleUpload() {
    if (_pendingUpload.length >= _uploadBatchSize) {
      _flushPendingTiles();
      return;
    }
    _uploadTimer?.cancel();
    _uploadTimer = Timer(_uploadDebounce, _flushPendingTiles);
  }

  Future<void> _flushPendingTiles() async {
    _uploadTimer?.cancel();
    if (_pendingUpload.isEmpty) return;

    final batch = {..._pendingUpload};
    _pendingUpload.clear();
    try {
      await fog.saveTiles(batch);
    } catch (_) {
      // Re-queue and re-arm the timer, or an idle user would never retry.
      _pendingUpload.addAll(batch);
      if (_disposed) return;
      _uploadTimer?.cancel();
      _uploadTimer = Timer(_uploadDebounce, _flushPendingTiles);
    }
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

  // Read path: the local set is a viewport cache; the database is the ledger.
  // Failures degrade silently, fog just stays as-is until the next map idle.
  Future<void> reloadFogInBounds({
    required double west,
    required double south,
    required double east,
    required double north,
  }) async {
    final List<FogTile> tiles;
    try {
      tiles = await fog.loadTilesInBounds(
        west: west,
        south: south,
        east: east,
        north: north,
      );
    } catch (_) {
      return;
    }
    if (_disposed) return;
    _exploredTiles = {...tiles, ..._pendingUpload};
    notifyListeners();
  }

  void toggleFog() {
    _fogEnabled = !_fogEnabled;
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
    _uploadTimer?.cancel();
    // Best-effort flush of the tail so the last few tiles aren't lost.
    _flushPendingTiles();
    location.dispose();
    super.dispose();
  }
}
