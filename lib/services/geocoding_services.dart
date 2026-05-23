import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jio_leh/config/map_env.dart';

class GeoCodingServices {
  Future<String> getLocationNameFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
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

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to get location name: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>?;

    if (features == null || features.isEmpty) {
      return 'Unknown location';
    }

    return features.first['place_name'] as String;
  }
}