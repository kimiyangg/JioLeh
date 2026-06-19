import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/services/account_service.dart';
import 'package:jio_leh/models/user_profile.dart';

/// A pretend AccountService for tests. No network — you set the fields from
/// your test to control what each method returns.
class FakeAccountService extends AccountService {
  FakeAccountService({
    this.hasProfile = false,
    this.profile,
    this.searchResult,
    this.throwUsernameTaken = false,
  });

  // Set these from a test to pretend different states.
  bool hasProfile; // what profileExists() returns
  UserProfile? profile; // what getUserProfile() / getProfileById() return
  UserProfile? searchResult; // what findByUsername() returns
  bool throwUsernameTaken; // make createProfile() fail like a real clash

  // Escape hatch: when set, profileExists() delegates here instead of returning
  // [hasProfile]. Lets a test control timing (with a Completer) or throw.
  Future<bool> Function()? profileExistsHandler;

  // Counters so tests can check "did create / update get called?".
  int createProfileCalls = 0;
  int updateProfileCalls = 0;

  @override
  Future<bool> profileExists() async {
    if (profileExistsHandler != null) return profileExistsHandler!();
    return hasProfile;
  }

  @override
  Future<UserProfile?> findByUsername(String username) async => searchResult;

  @override
  Future<UserProfile?> getProfileById(String userId) async => profile;

  @override
  Future<UserProfile> getUserProfile() async {
    final p = profile;
    if (p == null) throw StateError('No profile set in FakeAccountService');
    return p;
  }

  @override
  Future<void> createProfile({
    String? username,
    required String displayName,
    DateTime? birthday,
    XFile? profilePhoto,
  }) async {
    createProfileCalls++;
    if (throwUsernameTaken) throw const UsernameTaken();
    hasProfile = true; // a profile now exists
  }

  @override
  Future<UserProfile> updateProfile({
    required String displayName,
    String? bio,
    DateTime? birthday,
    XFile? profilePhoto,
  }) async {
    updateProfileCalls++;
    final current = profile;
    if (current == null) throw StateError('No profile to update');
    final updated = UserProfile(
      id: current.id,
      username: current.username,
      displayName: displayName,
      birthday: birthday,
      bio: bio,
      avatarUrl: current.avatarUrl,
    );
    profile = updated;
    return updated;
  }
}
