import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/services/geocoding_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

void main() {
  group('GeocodingService', () {
    test('fetchAreaName returns correct address', () async {
    final geocodingService = GeocodingService(
      httpClient: MockClient((req) async => http.Response(
        jsonEncode({'features': [{'properties': {'name': 'Bishan',
          'context': {'country': {'name': 'Singapore'}}}}]}), 200)),
    );
      final address = await geocodingService.fetchAreaName(
        latitude: 37.7749,
        longitude: -122.4194,
      );
      expect(address, 'Bishan, Singapore');
    });

    test('refetch is throttled correctly', () async {
      var apiCallCount = 0;
      final geocodingService = GeocodingService(
        minIntervalSeconds: 1,
        minDistanceMeters: 1000,
        httpClient: MockClient((req) async {
          apiCallCount++;
          return http.Response(
            jsonEncode({'features': [{'properties': {'name': 'Bishan',
              'context': {'country': {'name': 'Singapore'}}}}]}), 200);
        }),
      );

      // First fetch should call the API
      final address1 = await geocodingService.fetchAreaName(
        latitude: 37.7749,
        longitude: -122.4194,
      );
      expect(address1, 'Bishan, Singapore');
      expect(apiCallCount, 1);

      // Second fetch within interval and distance should return cached value
      final address2 = await geocodingService.fetchAreaName(
        latitude: 37.7750,
        longitude: -122.4195,
      );
      expect(address2, 'Bishan, Singapore');
      expect(apiCallCount, 1);

      // Third fetch after interval should call the API again
      await Future.delayed(Duration(seconds: 2));
      final address3 = await geocodingService.fetchAreaName(
        latitude: 1.290665504,
        longitude: 103.772663576,
      );
      expect(address3, 'Bishan, Singapore');
      expect(apiCallCount, 2);
    });


  });
}