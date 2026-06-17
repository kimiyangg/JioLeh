import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/models/user_inserted_pin.dart';

import 'package:jio_leh/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PinService {
  // `required this.auth` stores the injected AuthService in the auth field.
  PinService({required SupabaseClient client, required this.auth})
    : _supabase = client;

  final AuthService auth;
  final SupabaseClient _supabase;

  static const _placesTable = 'places';
  static const _userPinsTable = 'user_pins';
  static const _photoBucket = 'pin-photos';

  Future<void> saveUserInsertedPin(
    UserInsertedPin pin,
    List<XFile> photos,
  ) async {
    if (photos.length > 3) {
      throw Exception('Cannot upload more than 3 photos per pin');
    }

    final userId = auth.getCurrentUserId();
    String? placeId;
    String? pinId;
    final uploadedPaths = <String>[];

    try {
      final insertedPlace = await _supabase
          .from(_placesTable)
          .insert(pin.placeToMap(userId))
          .select('id')
          .single();

      placeId = insertedPlace['id'] as String;

      final insertedPin = await _supabase
          .from(_userPinsTable)
          .insert(pin.pinToMap(userId, placeId))
          .select('id')
          .single();

      pinId = insertedPin['id'] as String;

      for (var index = 0; index < photos.length; index++) {
        final photo = photos[index];
        final bytes = await photo.readAsBytes();
        final extension = _extensionFor(photo);
        final path = '$userId/$pinId/photo_${index + 1}.$extension';

        await _supabase.storage
            .from(_photoBucket)
            .uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(
                contentType: _contentTypeFor(photo, extension),
                upsert: false,
              ),
            );

        uploadedPaths.add(path);
      }

      if (uploadedPaths.isNotEmpty) {
        await _supabase
            .from(_userPinsTable)
            .update({'photo_paths': uploadedPaths})
            .eq('id', pinId);
      }
    } catch (_) {
      if (uploadedPaths.isNotEmpty) {
        try {
          await _supabase.storage.from(_photoBucket).remove(uploadedPaths);
        } catch (_) {
          // Preserve the original save error.
        }
      }

      if (pinId != null) {
        try {
          await _supabase.from(_userPinsTable).delete().eq('id', pinId);
        } catch (_) {
          // Preserve the original save error.
        }
      }

      if (placeId != null) {
        try {
          await _supabase.from(_placesTable).delete().eq('id', placeId);
        } catch (_) {
          // Preserve the original save error.
        }
      }

      rethrow;
    }
  }

  Future<List<Place>> loadPlacesNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 1,
  }) async {
    final latDelta = radiusKm / 111.0;
    final lngDelta = radiusKm / (111.0 * cos(latitude * pi / 180));

    final rows = await _supabase
        .from(_placesTable)
        .select(
          'id, name, latitude, longitude, pin_count, '
          'user_pins(id, user_id, place_id, custom_name, emoji, ratings, '
          'reviews, photo_paths, is_private)',
        )
        .gte('latitude', latitude - latDelta)
        .lte('latitude', latitude + latDelta)
        .gte('longitude', longitude - lngDelta)
        .lte('longitude', longitude + lngDelta);

    return rows
        .map(Place.fromMap)
        .where(
          (place) =>
              _distanceKm(
                latitude,
                longitude,
                place.latitude,
                place.longitude,
              ) <=
              radiusKm,
        )
        .toList();
  }

  Future<List<String>> createPhotoUrls(List<String> photoPaths) async {
    return Future.wait(
      photoPaths.map(
        (path) =>
            _supabase.storage.from(_photoBucket).createSignedUrl(path, 3600),
      ),
    );
  }

  String _extensionFor(XFile photo) {
    final fileName = photo.name.toLowerCase();
    final dotIndex = fileName.lastIndexOf('.');

    if (dotIndex == -1) return 'jpg';

    final extension = fileName.substring(dotIndex + 1);

    const allowedExtensions = {'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'};

    return allowedExtensions.contains(extension) ? extension : 'jpg';
  }

  String _contentTypeFor(XFile photo, String extension) {
    if (photo.mimeType != null) {
      return photo.mimeType!;
    }

    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      _ => 'image/jpeg',
    };
  }

  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
