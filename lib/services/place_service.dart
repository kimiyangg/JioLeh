import 'package:jio_leh/models/nearby_place.dart';

/// The interface for fetching real-world nearby places.
/// The whole app depend on this, so the real Google-backed service can be swapped for a fake in tests.
abstract class PlaceService {
  /// Fetches nearby places from a real-world service (e.g., Google Places API) based on the given location and radius.
  ///
  /// Returns a list of [NearbyPlace] objects representing the nearby places found within the specified radius.
  /// If failes to fetch, returns an empty list.
  Future<List<NearbyPlace>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radiusKm = 0.5,
  });

  /// Searches places by a free-text query (e.g. a name the user typed). Returns matches as [NearbyPlace]s, or an empty list if the search fails.
  Future<List<NearbyPlace>> searchPlaces({required String query});
}
