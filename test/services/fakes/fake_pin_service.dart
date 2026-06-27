import 'package:image_picker/image_picker.dart';

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
  });

  List<Place> places;
  List<String> photoUrls;
  bool throwOnSave;

  int saveUserInsertedPinCalls = 0;
  int loadPlacesNearLocationCalls = 0;
  int createPhotoUrlsCalls = 0;

  UserInsertedPin? lastSavedPin;
  List<XFile> lastSavedPhotos = const [];
  double? lastLatitude;
  double? lastLongitude;
  double? lastRadiusKm;
  List<String> lastPhotoPaths = const [];

  @override
  Future<void> saveUserInsertedPin(
    UserInsertedPin pin,
    List<XFile> photos,
  ) async {
    saveUserInsertedPinCalls++;
    lastSavedPin = pin;
    lastSavedPhotos = List.unmodifiable(photos);

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
  Future<List<String>> createPhotoUrls(List<String> photoPaths) async {
    createPhotoUrlsCalls++;
    lastPhotoPaths = List.unmodifiable(photoPaths);
    return photoUrls;
  }
}
