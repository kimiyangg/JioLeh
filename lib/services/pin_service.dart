import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/models/nearby_place.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/models/user_inserted_pin.dart';

/// The contract for pin/place operations. The whole app depends on this,
/// so the real Supabase service can be swapped for a fake in tests.
abstract class PinService {
  /// Saves a user-created place and its pin, optionally uploading up to three
  /// photos for that pin. Pass [existingPlaceId] to link the pin to an
  /// already-existing place instead of creating a new one.
  Future<void> saveUserInsertedPin(
    UserInsertedPin pin,
    List<XFile> photos, {
    String? existingPlaceId,
  });

  /// Loads places inside [radiusKm] of a map location.
  Future<List<Place>> loadPlacesNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 1,
  });

  /// Loads places whose coordinates fall inside the given bounding box.
  Future<List<Place>> loadPlacesInBounds({
    required double west,
    required double south,
    required double east,
    required double north,
  });

  /// Creates temporary display URLs for stored pin photo paths.
  Future<List<String>> createPhotoUrls(List<String> photoPaths);

  /// Looks up an existing place by its external provider id (e.g. a Google
  /// Places id). Returns null if no place has been created for it yet.
  Future<Place?> findPlaceByProvider({
    required String provider,
    required String providerPlaceId,
  });

  /// Returns the id of the places row for a provider-sourced [place], registering it first if it does not exist yet (find-or-create).
  Future<String> getOrCreateProviderPlaceId(
    NearbyPlace place, {
    String provider = 'google',
  });
}

class PinException implements Exception {
  final String message;
  const PinException(this.message);
  @override
  String toString() => message;
}

class DuplicatePinException extends PinException {
  const DuplicatePinException() : super('You have already pinned this place.');
}
