import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/models/user_pin.dart';

/// A place the current user pinned, paired with their own pin on it and a
/// ready-to-display photo URL (or null if they didn't upload one).
class PinnedSpotEntry {
  const PinnedSpotEntry({
    required this.place,
    required this.pin,
    this.thumbnailUrl,
  });

  final Place place;
  final UserPin pin;
  final String? thumbnailUrl;
}