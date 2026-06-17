import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/models/user_profile.dart';

class AccountService {
  final AuthService auth;
  final SupabaseClient _supabase;

  // Static table name for user profiles in the database
  static const _tableName = 'profiles';

  // Default bio assigned to new accounts that don't provide one during onboarding.
  static const _defaultBio =
      "New here and keen to meet some kakis. Always down for makan or a casual hang. Jio me la 🙂";

  // `required this.auth` stores the injected AuthService in the auth field.
  AccountService({required SupabaseClient client, required this.auth})
    : _supabase = client;

  Future<bool> profileExists() async {
    // Returns whether the current user has a profile row
    // i.e. whether they have completed onboarding
    final userId = auth.getCurrentUserId();

    final row = await _supabase
        .from(_tableName)
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    return row != null;
  }

  Future<void> createProfile({
    String? username,
    required String displayName,
    DateTime? birthday,
    XFile? profilePhoto,
  }) async {
    // Inserts the current user's profile row
    final userId = auth.getCurrentUserId();

    if (await profileExists()) {
      throw const ProfileAlreadyExists();
    }

    String? avatarUrl;

    if (profilePhoto != null) {
      final extension = profilePhoto.path.split('.').last.toLowerCase();
      final path = '$userId/avatar.$extension';
      final bytes = await profilePhoto.readAsBytes();

      await _supabase.storage
          .from('profile-photos')
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: profilePhoto.mimeType,
            ),
          );

      avatarUrl = _supabase.storage.from('profile-photos').getPublicUrl(path);
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
          'bio': _defaultBio,
          'avatar_url': avatarUrl,
          if (birthday != null)
            'birthday': birthday.toIso8601String().split('T').first,
        });

        return;
      } on PostgrestException catch (e) {
        // PostgrestException with code '23505' indicates a unique constraint violation
        // https://www.postgresql.org/docs/current/errcodes-appendix.html for more details

        // Only a generated username can be retried, a caller-supplied one
        // would collide forever, so the UsernameTaken exception will be thrown.
        if (e.code == '23505') {
          if (username == null) {
            continue;
          } else {
            throw const UsernameTaken();
          }
        }
        // Any other PostgrestException is rethrown for the caller to handle.
        rethrow;
      }
    }
    //
  }

  /// Looks up a profile by its username. Returns null if no user has it.
  Future<UserProfile?> findByUsername(String username) async {
    final row = await _supabase
        .from(_tableName)
        .select()
        .eq('username', username)
        .maybeSingle();

    return row == null ? null : UserProfile.fromMap(row);
  }

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

  /// Updates the current user's profile with the given display name, bio, and birthday.
  ///
  /// Returns the updated UserProfile after a successful update.
  Future<UserProfile> updateProfile({
    required String displayName,
    String? bio,
    DateTime? birthday,
    XFile? profilePhoto,
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

  /// Retrieves a user profile by its unique ID. Returns null if no profile is found.
  Future<UserProfile?> getProfileById(String userId) async {
    final row = await _supabase
        .from(_tableName)
        .select()
        .eq('id', userId)
        .maybeSingle();

    return row == null ? null : UserProfile.fromMap(row);
  }
}

/// Base class for all account-related exceptions
class AccountException implements Exception {
  final String message;
  const AccountException(this.message);
  @override
  String toString() => message;
}

/// Exception thrown when Username already taken
class UsernameTaken extends AccountException {
  const UsernameTaken() : super('Username Taken');
}

/// Exception thrown when the user already has a profile
class ProfileAlreadyExists extends AccountException {
  const ProfileAlreadyExists() : super('Profile already exists');
}
