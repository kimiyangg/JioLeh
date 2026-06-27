import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/models/user_inserted_pin.dart';

/// The contract for pin/place operations. The whole app depends on this,
/// so the real Supabase service can be swapped for a fake in tests.
abstract class PinService {
  /// Saves a user-created place and its pin, optionally uploading up to three
  /// photos for that pin.
  Future<void> saveUserInsertedPin(UserInsertedPin pin, List<XFile> photos);

  /// Loads places inside [radiusKm] of a map location.
  Future<List<Place>> loadPlacesNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 1,
  });

  /// Creates temporary display URLs for stored pin photo paths.
  Future<List<String>> createPhotoUrls(List<String> photoPaths);
}
