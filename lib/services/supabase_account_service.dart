import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/services/account_service.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/models/user_profile.dart';

/// The real [AccountService] used in production, backed by Supabase.
/// Write a sibling class if a new backend is needed in the future.
class SupabaseAccountService extends AccountService {
  final AuthService auth;
  final SupabaseClient _supabase;

  // Static table name for user profiles in the database
  static const _tableName = 'profiles';

  // `required this.auth` stores the injected AuthService in the auth field.
  SupabaseAccountService({required SupabaseClient client, required this.auth})
    : _supabase = client;

  @override
  Future<bool> profileExists() async {
    // Returns whether the current user has a profile row (whether they have completed onboarding)
    final userId = auth.getCurrentUserId();

    final row = await _supabase
        .from(_tableName)
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    return row != null;
  }

  @override
  Future<void> createProfile({
    String? username,
    required String displayName,
    DateTime? birthday,
    XFile? avatarFile,
  }) async {
    // Inserts the current user's profile row
    final userId = auth.getCurrentUserId();

    if (await profileExists()) {
      throw const ProfileAlreadyExists();
    }

    String? avatarUrl;
    if (avatarFile != null) {
      avatarUrl = await _uploadAvatar(avatarFile, userId);
    }

    // A generated username can randomly collide with an existing one, so keep
    // generating a fresh code and retrying until the insert succeeds.
    while (true) {
      // Fall back to a generated username when the caller doesn't supply one.
      final inputUserName = username ?? generateUserName();
      try {
        await _supabase.from(_tableName).insert({
          'id': userId,
          'username': inputUserName,
          'display_name': displayName,
          'bio': UserProfile.defaultBio,
          'avatar_url': avatarUrl,
          if (birthday != null)
            'birthday': birthday.toIso8601String().split('T').first,
        });

        return;
      } on PostgrestException catch (e) {
        // What to do depends only on the error code + whether the user gave a
        // username. That decision lives in [decideInsertAction] so it can be
        // unit-tested without a database.
        final action = decideInsertAction(
          errorCode: e.code,
          usernameGiven: username != null,
        );
        if (action == InsertAction.nameTaken) {
          throw const UsernameTaken();
        }
        if (action == InsertAction.unknownError) {
          rethrow;
        }
        // InsertAction.retry: loop again with a fresh generated username.
      }
    }
    //
  }

  /// Uploads [photo] to the profile-photos bucket under the user's own folder
  /// and returns its public URL.
  Future<String> _uploadAvatar(XFile photo, String userId) async {
    final extension = photo.path.split('.').last.toLowerCase();
    final path = '$userId/avatar.$extension';
    final bytes = await photo.readAsBytes();

    await _supabase.storage
        .from('profile-photos')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: photo.mimeType,
          ),
        );

    return _supabase.storage.from('profile-photos').getPublicUrl(path);
  }

  @override
  Future<UserProfile?> findByUsername(String username) async {
    final row = await _supabase
        .from(_tableName)
        .select()
        .eq('username', username)
        .maybeSingle();

    return row == null ? null : UserProfile.fromMap(row);
  }

  @override
  Future<UserProfile> getUserProfile() async {
    // Retrieves the current user's profile row from the 'profiles' table.
    final userId = auth.getCurrentUserId();

    final profile = await _supabase
        .from(_tableName)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (profile == null) {
      throw StateError('Profile not found for user ID: $userId');
    }

    return UserProfile.fromMap(profile);
  }

  @override
  Future<UserProfile> updateProfile({
    required String displayName,
    String? bio,
    DateTime? birthday,
    XFile? avatarFile,
  }) async {
    final userId = auth.getCurrentUserId();

    final row = await _supabase
        .from(_tableName)
        .update({
          'display_name': displayName,
          'bio': bio,
          'birthday': birthday?.toIso8601String().split('T').first,
        })
        .eq('id', userId)
        .select()
        .single();

    return UserProfile.fromMap(row);
  }

  /// Generates a random username consisting of 8 lowercase letters and digits.
  ///
  /// Returns a string that can be used as a default username
  String generateUserName() {
    final random = Random();
    final letters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    String code = '';
    for (int i = 0; i < 8; i++) {
      code += letters[random.nextInt(letters.length)];
    }
    return code;
  }

  @override
  Future<UserProfile?> getProfileById(String userId) async {
    final row = await _supabase
        .from(_tableName)
        .select()
        .eq('id', userId)
        .maybeSingle();

    return row == null ? null : UserProfile.fromMap(row);
  }
}

/// What [SupabaseAccountService.createProfile] should do when an insert fails.
enum InsertAction { retry, nameTaken, unknownError }

/// Decides what to do when a profile insert fails, from the Postgres
/// [errorCode] and whether the user gave their own username.
///
/// A duplicate (23505) on a generated name → try again with a new one; on a
/// user-chosen name → the name is taken; anything else → an unknown error.
InsertAction decideInsertAction({
  required String? errorCode,
  required bool usernameGiven,
}) {
  const duplicateCode = '23505';
  if (errorCode != duplicateCode) return InsertAction.unknownError;
  return usernameGiven ? InsertAction.nameTaken : InsertAction.retry;
}
