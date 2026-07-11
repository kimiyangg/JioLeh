import 'package:jio_leh/models/nearby_place.dart';
import 'package:jio_leh/services/place_service.dart';

/// A pretend PlaceService for tests. No network - you set `places` from your
/// test to control what getNearbyPlaces returns.
class FakePlaceService extends PlaceService {
  FakePlaceService({this.places = const [], this.searchResults = const []});

  List<NearbyPlace> places;
  List<NearbyPlace> searchResults;

  int getNearbyPlacesCalls = 0;
  double? lastLatitude;
  double? lastLongitude;
  double? lastRadiusKm;

  int searchPlacesCalls = 0;
  String? lastQuery;

  @override
  Future<List<NearbyPlace>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radiusKm = 0.5,
  }) async {
    getNearbyPlacesCalls++;
    lastLatitude = latitude;
    lastLongitude = longitude;
    lastRadiusKm = radiusKm;
    return places;
  }

  @override
  Future<List<NearbyPlace>> searchPlaces({required String query}) async {
    searchPlacesCalls++;
    lastQuery = query;
    return searchResults;
  }
}
