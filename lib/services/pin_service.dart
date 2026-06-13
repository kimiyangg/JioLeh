import 'package:image_picker/image_picker.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/models/pinned_location.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class PinService {
  PinService(this.auth);
  final AuthService auth;

  // The Supabase client is shared from AuthService so there is a single
  // source of truth for which client this app talks to.

  // This getter exists purely as a convenience alias so the method bodies can write
  // _supabase.from(...) instead of the noisier auth.client.from(...) 
  SupabaseClient get _supabase => auth.client;

  // Static table name for pinned locations in the database
  static const _tableName = 'pinned_locations';
  static const _photoBucket = 'pin-photos';


  Future<void> savePinnedLocation(PinnedLocation pin, List<XFile> photos,) async {
    if (photos.length > 3) {
      throw Exception('Cannot upload more than 3 photos per pin');
    }
    final userId = auth.getCurrentUserId();
    String? pinId;
    final uploadedPaths = <String>[];

    try {
      final insertedRow = await _supabase
          .from(_tableName)
          .insert(pin.toMap(userId))
          .select('id')
          .single();

      pinId = insertedRow['id'] as String;

      for (var index = 0; index < photos.length; index++) {
        final photo = photos[index];
        final bytes = await photo.readAsBytes();
        final extension = _extensionFor(photo);
        final path = '$userId/$pinId/photo_${index + 1}.$extension';

        await _supabase.storage.from(_photoBucket).uploadBinary(
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
            .from(_tableName)
            .update({'photo_paths': uploadedPaths})
            .eq('id', pinId);
      }
    } catch (_) {
      if (uploadedPaths.isNotEmpty) {
        try {
          await _supabase.storage
              .from(_photoBucket)
              .remove(uploadedPaths);
        } catch (_) {
          // Preserve the original save error.
        }
      }

      if (pinId != null) {
        try {
          await _supabase.from(_tableName).delete().eq('id', pinId);
        } catch (_) {
          // Preserve the original save error.
        }
      }

      rethrow;
    }
  }

  Future<List<PinnedLocation>> loadPinnedLocations() async {
    final userId = auth.getCurrentUserId();

    final data = await _supabase
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return data.map(PinnedLocation.fromMap).toList();
  }

  Future<List<String>> createPhotoUrls(
    List<String> photoPaths,
  ) async {
    return Future.wait(
      photoPaths.map(
        (path) => _supabase.storage
            .from(_photoBucket)
            .createSignedUrl(path, 3600),
      ),
    );
  }

  String _extensionFor(XFile photo) {
    final fileName = photo.name.toLowerCase();
    final dotIndex = fileName.lastIndexOf('.');

    if (dotIndex == -1) return 'jpg';

    final extension = fileName.substring(dotIndex + 1);

    const allowedExtensions = {
      'jpg',
      'jpeg',
      'png',
      'webp',
      'heic',
      'heif',
    };

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
}
