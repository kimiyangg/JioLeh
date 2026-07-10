import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/pages/map/models/pin_type.dart';

class LocationFormResult {
  final PinType pinType;
  // The official/formal name of the place (maps to places.name later).
  final String formalName;
  // The place's own coordinates (from search/link), or null for a custom
  // place, in which case the caller should fall back to the device position.
  final double? latitude;
  final double? longitude;
  // The user's own preference name for the pin (maps to user_pins.custom_name).
  final String name;
  final int rating;
  final String review;
  final bool? isPrivate;
  final List<XFile> selectedPhotos;
  final List<String> photoUrls;
  // Set when the user links to an already-existing place instead of
  // creating a new one; null means "create a new place from formalName".
  final String? existingPlaceId;
  // Set when formalName came from a "Find nearby" (Google) pick, so the
  // new place can be deduped against an existing provider place.
  final String? provider;
  final String? providerPlaceId;

  const LocationFormResult({
    this.pinType = PinType.restaurant,
    this.formalName = '',
    this.latitude,
    this.longitude,
    required this.name,
    required this.rating,
    required this.review,
    this.isPrivate,
    this.selectedPhotos = const [],
    this.photoUrls = const [],
    this.existingPlaceId,
    this.provider,
    this.providerPlaceId,
  });
}
