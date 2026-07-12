import 'package:flutter/foundation.dart';
import 'package:jio_leh/models/nearby_place.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/services/location_service.dart';
import 'package:jio_leh/services/pin_service.dart';
import 'package:jio_leh/services/place_service.dart';

/// Presentation state and logic for OpenJioFormPage's location picking.
/// Owns the search/popular-nearby flow; UI-only effects (snackbars, sheets) stay in the widget.
class OpenJioFormPageModel extends ChangeNotifier {
  OpenJioFormPageModel({
    required this.place,
    required this.pins,
    required this.location,
  });

  final PlaceService place;
  final PinService pins;
  final LocationService location;

  bool _disposed = false;

  NearbyPlace? _selectedPlace;
  NearbyPlace? get selectedPlace => _selectedPlace;

  // Set when the selection came from an already-registered place; provider picks resolve lazily on submit.
  String? _selectedDbPlaceId;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  List<NearbyPlace> _searchResults = const [];
  List<NearbyPlace> get searchResults => _searchResults;

  bool _loadingNearby = false;
  bool get loadingNearby => _loadingNearby;

  List<Place> _nearbyPopularPlaces = const [];
  List<Place> get nearbyPopularPlaces => _nearbyPopularPlaces;

  Future<void> searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || _isSearching) return;

    _isSearching = true;
    notifyListeners();

    final results = await place.searchPlaces(query: trimmed);
    if (_disposed) return;

    _searchResults = results;
    _isSearching = false;
    notifyListeners();
  }

  /// Loads places near the user's current position. Rethrows [LocationException] for the widget to surface.
  Future<void> loadPopularNearby() async {
    if (_loadingNearby) return;

    _loadingNearby = true;
    notifyListeners();

    try {
      final position = await location.getCurrentLocation();
      final places = await pins.loadPlacesNearLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (_disposed) return;
      _nearbyPopularPlaces = places;
    } finally {
      if (!_disposed) {
        _loadingNearby = false;
        notifyListeners();
      }
    }
  }

  void selectPlace(NearbyPlace chosen) {
    _selectedPlace = chosen;
    _selectedDbPlaceId = null;
    notifyListeners();
  }

  void selectExistingPlace(Place chosen) {
    _selectedPlace = NearbyPlace(
      placeId: '',
      name: chosen.name,
      latitude: chosen.latitude,
      longitude: chosen.longitude,
    );
    _selectedDbPlaceId = chosen.id;
    notifyListeners();
  }

  void clearSelectedPlace() {
    if (_selectedPlace == null) return;
    _selectedPlace = null;
    _selectedDbPlaceId = null;
    notifyListeners();
  }

  /// Resolves the places-row id for the current selection, registering a provider place on first use. Best-effort: a failed lookup returns null so the event still saves with just its location name.
  Future<String?> resolvePlaceId() async {
    final selected = _selectedPlace;
    if (selected == null) return null;
    if (_selectedDbPlaceId != null) return _selectedDbPlaceId;
    if (selected.placeId.isEmpty) return null;

    try {
      return await pins.getOrCreateProviderPlaceId(selected);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
