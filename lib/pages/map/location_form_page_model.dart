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

  // when _lockedCategory is null, it means its free to choose and not determined
  String? _lockedCategory;
  bool get isTypeLocked => _lockedCategory != null;


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

  Place? _selectedExistingPlace;
  String? get selectedExistingPlaceId => _selectedExistingPlace?.id;

  NearbyPlace? _selectedNearbyPlace;
  NearbyPlace? get selectedNearbyPlace => _selectedNearbyPlace;

  double? get markerLatitude =>
      _selectedNearbyPlace?.latitude ?? _selectedExistingPlace?.latitude ?? latitude;
  double? get markerLongitude =>
      _selectedNearbyPlace?.longitude ?? _selectedExistingPlace?.longitude ?? longitude;

  bool _isEnteringManually = false;
  bool get isEnteringManually => _isEnteringManually;

  bool get canSearchPlaces => latitude != null && longitude != null;

  String? get placeSourceLabel {
    if (_selectedNearbyPlace != null) return 'From Google';
    if (_selectedExistingPlace != null) return 'Linked from an existing pin';
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

  Future<void> selectSuggestion(NearbyPlace suggestion) async {
    _selectedNearbyPlace = suggestion;
    _selectedExistingPlace = null;
    _lockedCategory = null;
    notifyListeners();

    Place? existingPlace;
    try {
      existingPlace = await pins.findPlaceByProvider(
        provider: 'google',
        providerPlaceId: suggestion.placeId,
      );
    } catch (_) {
      // Best-effort pre-fill: a failed lookup just means no suggestion, not an error.
      return;
    }
    if (_disposed) return;

    final category = existingPlace?.category;
    if (category == null) return;

    _lockedCategory = category;

    final matchingType = PinType.values.firstWhere(
      (type) => type.emoji == category,
      orElse: () => _currentType,
    );
    setCurrentType(matchingType);
  }

  void selectExistingPlace(Place existingPlace) {
    _selectedExistingPlace = existingPlace;
    _selectedNearbyPlace = null;

    final category = existingPlace.category;
    _lockedCategory = category;
    if (category != null) {
      _currentType = PinType.values.firstWhere(
        (type) => type.emoji == category,
        orElse: () => _currentType,
      );
    }

    notifyListeners();
  }

  void resetPlaceSelection() {
    _selectedNearbyPlace = null;
    _selectedExistingPlace = null;
    _isEnteringManually = false;
    _lockedCategory = null;
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
      latitude: markerLatitude,
      longitude: markerLongitude,
      name: name,
      review: review,
      rating: _rating,
      isPrivate: _isPrivate,
      selectedPhotos: List.unmodifiable(selectedPhotos),
      existingPlaceId: _selectedExistingPlace?.id,
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
