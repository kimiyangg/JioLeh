import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:jio_leh/services/google_place_service.dart';

void main() {
  group('GooglePlaceService.getNearbyPlaces', () {
    test('parses multiple results from a successful response', () async {
      final service = GooglePlaceService(
        httpClient: MockClient((req) async {
          return http.Response(
            jsonEncode({
              'places': [
                {
                  'id': 'place-1',
                  'displayName': {'text': 'Kopi Place'},
                  'formattedAddress': '123 Example Rd',
                  'location': {'latitude': 1.35, 'longitude': 103.82},
                },
                {
                  'id': 'place-2',
                  'displayName': {'text': 'Riverside Park'},
                  'location': {'latitude': 1.36, 'longitude': 103.83},
                },
              ],
            }),
            200,
          );
        }),
      );

      final places = await service.getNearbyPlaces(
        latitude: 1.35,
        longitude: 103.82,
      );

      expect(places, hasLength(2));
      expect(places[0].placeId, 'place-1');
      expect(places[0].name, 'Kopi Place');
      expect(places[1].address, isNull);
    });

    test('sends the expected request shape', () async {
      late http.Request captured;
      final service = GooglePlaceService(
        httpClient: MockClient((req) async {
          captured = req;
          return http.Response(jsonEncode({'places': []}), 200);
        }),
      );

      await service.getNearbyPlaces(
        latitude: 1.35,
        longitude: 103.82,
        radiusKm: 0.5,
      );

      expect(captured.method, 'POST');
      expect(captured.url.host, 'places.googleapis.com');
      expect(captured.url.path, '/v1/places:searchNearby');
      expect(
        captured.headers['X-Goog-FieldMask'],
        'places.id,places.displayName,places.location,places.formattedAddress',
      );

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      final circle =
          body['locationRestriction']['circle'] as Map<String, dynamic>;
      expect(circle['center']['latitude'], 1.35);
      expect(circle['center']['longitude'], 103.82);
      expect(circle['radius'], 500);
    });

    test('returns an empty list on a non-200 response', () async {
      final service = GooglePlaceService(
        httpClient: MockClient((req) async {
          return http.Response('rate limited', 429);
        }),
      );

      final places = await service.getNearbyPlaces(
        latitude: 1.35,
        longitude: 103.82,
      );

      expect(places, isEmpty);
    });

    test('returns an empty list when the response body is malformed', () async {
      final service = GooglePlaceService(
        httpClient: MockClient((req) async {
          return http.Response('not json', 200);
        }),
      );

      final places = await service.getNearbyPlaces(
        latitude: 1.35,
        longitude: 103.82,
      );

      expect(places, isEmpty);
    });
  });

  group('GooglePlaceService.searchPlaces', () {
    test('parses multiple results from a successful response', () async {
      final service = GooglePlaceService(
        httpClient: MockClient((req) async {
          return http.Response(
            jsonEncode({
              'places': [
                {
                  'id': 'place-1',
                  'displayName': {'text': 'Lau Pa Sat'},
                  'formattedAddress': '18 Raffles Quay',
                  'location': {'latitude': 1.28, 'longitude': 103.85},
                },
                {
                  'id': 'place-2',
                  'displayName': {'text': 'Lau Pa Sat Satay Street'},
                  'location': {'latitude': 1.28, 'longitude': 103.85},
                },
              ],
            }),
            200,
          );
        }),
      );

      final places = await service.searchPlaces(query: 'lau pa sat');

      expect(places, hasLength(2));
      expect(places[0].placeId, 'place-1');
      expect(places[0].name, 'Lau Pa Sat');
      expect(places[1].address, isNull);
    });

    test('sends the expected request shape', () async {
      late http.Request captured;
      final service = GooglePlaceService(
        httpClient: MockClient((req) async {
          captured = req;
          return http.Response(jsonEncode({'places': []}), 200);
        }),
      );

      await service.searchPlaces(query: 'lau pa sat');

      expect(captured.method, 'POST');
      expect(captured.url.host, 'places.googleapis.com');
      expect(captured.url.path, '/v1/places:searchText');
      expect(
        captured.headers['X-Goog-FieldMask'],
        'places.id,places.displayName,places.location,places.formattedAddress',
      );

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['textQuery'], 'lau pa sat');
    });

    test('returns an empty list on a non-200 response', () async {
      final service = GooglePlaceService(
        httpClient: MockClient((req) async {
          return http.Response('rate limited', 429);
        }),
      );

      final places = await service.searchPlaces(query: 'lau pa sat');

      expect(places, isEmpty);
    });

    test('returns an empty list when the response body is malformed', () async {
      final service = GooglePlaceService(
        httpClient: MockClient((req) async {
          return http.Response('not json', 200);
        }),
      );

      final places = await service.searchPlaces(query: 'lau pa sat');

      expect(places, isEmpty);
    });
  });
}
