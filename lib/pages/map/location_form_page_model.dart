import 'package:flutter/foundation.dart';
import 'package:jio_leh/models/nearby_place.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/pages/map/models/location_form_result.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';
import 'package:jio_leh/services/pin_service.dart';
import 'package:jio_leh/services/place_service.dart';
import 'package:image_picker/image_picker.dart';

/// Presentation state and logic for LocationFormPage.
/// Owns place search/link/save flow; UI-only effects (snackbars, navigation, dialogs) stay in the widget.
class LocationFormPageModel extends ChangeNotifier {
  LocationFormPageModel({
    required this.place,
    required this.pins,
    required this.selectedType,
    this.initialValue,
    this.latitude,
    this.longitude,
  });

  final PlaceService place;
  final PinService pins;
  final PinType selectedType;
  final LocationFormResult? initialValue;
  final double? latitude;
  final double? longitude;

  bool _disposed = false;

  late PinType _currentType;
  PinType get currentType => _currentType;

  late int _rating;
  int get rating => _rating;

  bool? _isPrivate;
  bool? get isPrivate => _isPrivate;

  var _isSaving = false;
  bool get isSaving => _isSaving;

  bool _suggestionsFetched = false;
  bool get suggestionsFetched => _suggestionsFetched;

  bool _loadingSuggestions = false;
  bool get loadingSuggestions => _loadingSuggestions;

  List<NearbyPlace> _nearbyPlaces = const [];
  List<NearbyPlace> get nearbyPlaces => _nearbyPlaces;

  bool _existingPlacesFetched = false;
  bool get existingPlacesFetched => _existingPlacesFetched;

  bool _loadingExistingPlaces = false;
  bool get loadingExistingPlaces => _loadingExistingPlaces;

  List<Place> _existingPlaces = const [];
  List<Place> get existingPlaces => _existingPlaces;

  String? _selectedExistingPlaceId;
  String? get selectedExistingPlaceId => _selectedExistingPlaceId;

  NearbyPlace? _selectedNearbyPlace;
  NearbyPlace? get selectedNearbyPlace => _selectedNearbyPlace;

  bool _isEnteringManually = false;
  bool get isEnteringManually => _isEnteringManually;

  bool get canSearchPlaces => latitude != null && longitude != null;

  String? get placeSourceLabel {
    if (_selectedNearbyPlace != null) return 'From Google';
    if (_selectedExistingPlaceId != null) return 'Linked from an existing pin';
    return null;
  }

  bool hasChosenPlace(String formalNameText) =>
      !_isEnteringManually && formalNameText.trim().isNotEmpty;

  void start() {
    _currentType = selectedType;
    _rating = initialValue?.rating ?? 0;
    _isPrivate = initialValue?.isPrivate;
  }

  void setCurrentType(PinType type) {
    _currentType = type;
    notifyListeners();
  }

  void setRating(int rating) {
    _rating = rating;
    notifyListeners();
  }

  void setIsPrivate(bool isPrivate) {
    _isPrivate = isPrivate;
    notifyListeners();
  }

  void enterManually() {
    _isEnteringManually = true;
    notifyListeners();
  }

  void selectSuggestion(NearbyPlace suggestion) {
    _selectedNearbyPlace = suggestion;
    _selectedExistingPlaceId = null;
    notifyListeners();
  }

  void selectExistingPlace(Place existingPlace) {
    _selectedExistingPlaceId = existingPlace.id;
    _selectedNearbyPlace = null;
    notifyListeners();
  }

  void resetPlaceSelection() {
    _selectedNearbyPlace = null;
    _selectedExistingPlaceId = null;
    _isEnteringManually = false;
    notifyListeners();
  }

  Future<void> onFindNearbyPressed() async {
    if (_suggestionsFetched) return;

    final lat = latitude;
    final lng = longitude;
    if (lat == null || lng == null) return;

    _loadingSuggestions = true;
    notifyListeners();

    final places = await place.getNearbyPlaces(latitude: lat, longitude: lng);
    if (_disposed) return;

    _nearbyPlaces = places;
    _suggestionsFetched = true;
    _loadingSuggestions = false;
    notifyListeners();
  }

  Future<void> onLinkExistingPressed() async {
    if (_existingPlacesFetched) return;

    final lat = latitude;
    final lng = longitude;
    if (lat == null || lng == null) return;

    _loadingExistingPlaces = true;
    notifyListeners();

    final places = await pins.loadPlacesNearLocation(
      latitude: lat,
      longitude: lng,
      radiusKm: 0.5,
    );
    if (_disposed) return;

    _existingPlaces = places;
    _existingPlacesFetched = true;
    _loadingExistingPlaces = false;
    notifyListeners();
  }

  /// Returns the built result, or null if validation failed (no visibility chosen) — caller should show a snackbar.
  /// Rethrows if [onSave] throws — caller should catch and show a snackbar.
  Future<LocationFormResult?> save({
    required String formalName,
    required String name,
    required String review,
    required List<XFile> selectedPhotos,
    required Future<void> Function(LocationFormResult result)? onSave,
  }) async {
    if (_isPrivate == null) return null;

    final result = LocationFormResult(
      pinType: _currentType,
      formalName: formalName,
      name: name,
      review: review,
      rating: _rating,
      isPrivate: _isPrivate,
      selectedPhotos: List.unmodifiable(selectedPhotos),
      existingPlaceId: _selectedExistingPlaceId,
      provider: _selectedNearbyPlace == null ? null : 'google',
      providerPlaceId: _selectedNearbyPlace?.placeId,
    );

    if (onSave == null) return result;

    _isSaving = true;
    notifyListeners();

    try {
      await onSave(result);
      return result;
    } catch (error) {
      if (_disposed) rethrow;
      _isSaving = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
