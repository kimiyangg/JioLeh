import 'package:jio_leh/config/place_env.dart';
import 'package:jio_leh/models/nearby_place.dart';
import 'package:jio_leh/services/place_service.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

class GooglePlaceService extends PlaceService {
  GooglePlaceService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  Future<List<NearbyPlace>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radiusKm = 0.5,
  }) async {
    try {
      final uri = Uri.https('places.googleapis.com', '/v1/places:searchNearby');

      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': PlaceEnv.googlePlacesApiKey,
          'X-Goog-FieldMask':
              'places.id,places.displayName,places.location,places.formattedAddress',
        },
        body: jsonEncode({
          'locationRestriction': {
            'circle': {
              'center': {'latitude': latitude, 'longitude': longitude},
              'radius': radiusKm * 1000,
            },
          },
        }),
      );

      if (response.statusCode != 200) {
        return const [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final places = data['places'] as List<dynamic>? ?? const [];

      return places
          .map((place) => NearbyPlace.fromMap(place as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<NearbyPlace>> searchPlaces({required String query}) async {
    try {
      final uri = Uri.https('places.googleapis.com', '/v1/places:searchText');

      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': PlaceEnv.googlePlacesApiKey,
          'X-Goog-FieldMask':
              'places.id,places.displayName,places.location,places.formattedAddress',
        },
        body: jsonEncode({'textQuery': query}),
      );

      if (response.statusCode != 200) {
        return const [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final places = data['places'] as List<dynamic>? ?? const [];

      return places
          .map((place) => NearbyPlace.fromMap(place as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
