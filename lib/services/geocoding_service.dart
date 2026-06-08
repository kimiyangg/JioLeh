import 'dart:convert';

import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:jio_leh/config/map_env.dart';

class GeocodingService {
  GeocodingService({
    this.minIntervalSeconds = 20,
    this.minDistanceMeters = 100,
    // Allows injection of a custom HTTP client for testing purposes
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();


  final int minIntervalSeconds;
  final int minDistanceMeters;
  final http.Client _httpClient;

  ({DateTime time, double lat, double lng, String name})? _lastFetch;

  bool shouldRefetchLocation({
    required double latitude,
    required double longitude,
  }) {
    // Determines if a reverse geocoding request should be throttled based on time and distance thresholds.
    //
    // Copy fields to locals so Dart can type-promote them to non-null after the
    // null check below. Dart won't promote instance fields directly (they could
    // be reassigned between the check and the use), but locals are safe.
    final lastFetched = _lastFetch;

    if (lastFetched == null) return true;

    final recentlyUpdated =
        DateTime.now().difference(lastFetched.time).inSeconds < minIntervalSeconds;

    final notMovedMuch = geo.Geolocator.distanceBetween(
      lastFetched.lat,
      lastFetched.lng,
      latitude,
      longitude,
    ) < minDistanceMeters;

    return !(recentlyUpdated && notMovedMuch);
  }

  Future<String> fetchAreaName({
    required double latitude,
    required double longitude,
  }) async {
    // Fetches a human-readable area name for the given latitude and longitude
    // using Mapbox's reverse geocoding API.
    if (!shouldRefetchLocation(
      latitude: latitude,
      longitude: longitude,
    )){
      return _lastFetch!.name;
    }

    final name = await _reverseGeocode(
      latitude: latitude,
      longitude: longitude,
    );
    _lastFetch = (time: DateTime.now(), lat: latitude, lng: longitude, name: name);
    return name;
  }

  Future<String> _reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    // Helper method that performs the actual reverse geocoding API call to Mapbox
    // and parses the response to extract a user-friendly location name.
    final uri = Uri.https(
      'api.mapbox.com',
      '/search/geocode/v6/reverse',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'language': 'en',
        'access_token': MapEnv.mapboxAccessToken,
      },
    );

    final response = await _httpClient.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to get location name: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>?;

    if (features == null || features.isEmpty) {
      return 'Unknown location';
    }

    final firstFeature = features.first as Map<String, dynamic>;
    final properties =
        firstFeature['properties'] as Map<String, dynamic>? ?? {};
    final context = properties['context'] as Map<String, dynamic>? ?? {};

    final name = properties['name'] as String?;

    final neighborhood = context['neighborhood']?['name'] as String?;
    final locality = context['locality']?['name'] as String?;
    final district = context['district']?['name'] as String?;
    final place = context['place']?['name'] as String?;
    final region = context['region']?['name'] as String?;
    final country = context['country']?['name'] as String?;

    // Construct a user-friendly location name by prioritizing more specific area names
    final area = neighborhood ?? locality ?? district ?? place ?? region ?? name;

    // If both area and country are available and different, return "area, country". 
    if (area != null && country != null && area != country) {
      return '$area, $country';
    }
    // Otherwise, return whichever is available or "Unknown location" if neither is found.
    return area ?? country ?? 'Unknown location';
  }
}
