import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/models/user_profile.dart';

/// The contract for account/profile operations. The whole app depends on this,
/// so the real Supabase service can be swapped for a fake in tests.
/// Write a sibling class if a new backend is needed in the future.
abstract class AccountService {
  /// Whether the current user has a profile row — i.e. whether they have
  /// completed onboarding.
  Future<bool> profileExists();

  /// Inserts the current user's profile row.
  ///
  /// Falls back to a generated username when [username] is null. Throws
  /// [ProfileAlreadyExists] if the user already has a profile, and
  /// [UsernameTaken] when a caller-supplied username collides.
  Future<void> createProfile({
    String? username,
    required String displayName,
    DateTime? birthday,
    XFile? avatarFile,
  });

  /// Looks up a profile by its username. Returns null if no user has it.
  Future<UserProfile?> findByUsername(String username);

  /// Retrieves the current user's profile row.
  Future<UserProfile> getUserProfile();

  /// Updates the current user's profile and returns the updated profile.
  Future<UserProfile> updateProfile({
    required String displayName,
    String? bio,
    DateTime? birthday,
    XFile? avatarFile,
  });

  /// Retrieves a user profile by its unique ID. Returns null if none is found.
  Future<UserProfile?> getProfileById(String userId);
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
