import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/models/nearby_place.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/models/user_inserted_pin.dart';
import 'package:jio_leh/services/pin_service.dart';

/// A pretend PinService for tests. No network - you set the fields from your
/// test to control what each method returns.
class FakePinService extends PinService {
  FakePinService({
    this.places = const [],
    this.photoUrls = const [],
    this.throwOnSave = false,
    this.findPlaceByProviderResult,
    this.throwOnFindPlaceByProvider = false,
    this.providerPlaceIdResult = 'fake-place-id',
    this.throwOnGetOrCreateProviderPlaceId = false,
  });

  List<Place> places;
  List<String> photoUrls;
  bool throwOnSave;
  Place? findPlaceByProviderResult;
  bool throwOnFindPlaceByProvider;
  String providerPlaceIdResult;
  bool throwOnGetOrCreateProviderPlaceId;

  int saveUserInsertedPinCalls = 0;
  int loadPlacesNearLocationCalls = 0;
  int loadPlacesInBoundsCalls = 0;
  int createPhotoUrlsCalls = 0;
  int findPlaceByProviderCalls = 0;

  UserInsertedPin? lastSavedPin;
  List<XFile> lastSavedPhotos = const [];
  String? lastExistingPlaceId;
  double? lastLatitude;
  double? lastLongitude;
  double? lastRadiusKm;
  double? lastWest;
  double? lastSouth;
  double? lastEast;
  double? lastNorth;
  List<String> lastPhotoPaths = const [];
  String? lastProvider;
  String? lastProviderPlaceId;

  @override
  Future<void> saveUserInsertedPin(
    UserInsertedPin pin,
    List<XFile> photos, {
    String? existingPlaceId,
  }) async {
    saveUserInsertedPinCalls++;
    lastSavedPin = pin;
    lastSavedPhotos = List.unmodifiable(photos);
    lastExistingPlaceId = existingPlaceId;

    if (throwOnSave) {
      throw StateError('FakePinService save failed');
    }
  }

  @override
  Future<List<Place>> loadPlacesNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 1,
  }) async {
    loadPlacesNearLocationCalls++;
    lastLatitude = latitude;
    lastLongitude = longitude;
    lastRadiusKm = radiusKm;
    return places;
  }

  @override
  Future<List<Place>> loadPlacesInBounds({
    required double west,
    required double south,
    required double east,
    required double north,
  }) async {
    loadPlacesInBoundsCalls++;
    lastWest = west;
    lastSouth = south;
    lastEast = east;
    lastNorth = north;
    return places;
  }

  @override
  Future<List<String>> createPhotoUrls(List<String> photoPaths) async {
    createPhotoUrlsCalls++;
    lastPhotoPaths = List.unmodifiable(photoPaths);
    return photoUrls;
  }

  @override
  Future<Place?> findPlaceByProvider({
    required String provider,
    required String providerPlaceId,
  }) async {
    findPlaceByProviderCalls++;
    lastProvider = provider;
    lastProviderPlaceId = providerPlaceId;

    if (throwOnFindPlaceByProvider) {
      throw StateError('FakePinService findPlaceByProvider failed');
    }

    return findPlaceByProviderResult;
  }

  int getOrCreateProviderPlaceIdCalls = 0;
  NearbyPlace? lastGetOrCreatePlace;

  @override
  Future<String> getOrCreateProviderPlaceId(
    NearbyPlace place, {
    String provider = 'google',
  }) async {
    getOrCreateProviderPlaceIdCalls++;
    lastGetOrCreatePlace = place;
    lastProvider = provider;

    if (throwOnGetOrCreateProviderPlaceId) {
      throw StateError('FakePinService getOrCreateProviderPlaceId failed');
    }

    return providerPlaceIdResult;
  }
}
