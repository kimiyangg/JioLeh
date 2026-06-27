import 'package:flutter/foundation.dart';

import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/services/account_service.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/friends_service.dart';

/// Presentation state and logic for [ProfilePage].
///
/// This model owns profile loading and friend-request state. UI-only effects
/// such as snack bars and navigation stay in the widget that consumes it.
class ProfilePageModel extends ChangeNotifier {
  ProfilePageModel({
    required this.account,
    required this.friends,
    required this.auth,
    this.userId,
  });

  final AccountService account;
  final FriendsService friends;
  final AuthService auth;
  final String? userId;

  UserProfile? _profile;
  bool _isLoading = true;
  String? _error;
  bool _sendingFriendRequest = false;
  bool _friendRequestSent = false;
  bool _isAlreadyFriend = false;
  bool _disposed = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get sendingFriendRequest => _sendingFriendRequest;
  bool get friendRequestSent => _friendRequestSent;
  bool get isAlreadyFriend => _isAlreadyFriend;

  bool get isOwnProfile {
    final loadedProfile = _profile;
    if (loadedProfile == null) return false;

    return loadedProfile.id == auth.getCurrentUserId();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loadedProfile = userId == null
          ? await account.getUserProfile()
          : await account.getProfileById(userId!);

      if (_disposed) return;

      if (loadedProfile == null) {
        _profile = null;
        _isAlreadyFriend = false;
        _isLoading = false;
        _error = 'Profile not found.';
        notifyListeners();
        return;
      }

      final currentUserId = auth.getCurrentUserId();
      var alreadyFriend = false;
      if (loadedProfile.id != currentUserId) {
        final userFriends = await friends.getUserFriends();
        if (_disposed) return;

        alreadyFriend = userFriends.any(
          (friend) =>
              friend.isAccepted && friend.userProfile.id == loadedProfile.id,
        );
      }

      _profile = loadedProfile;
      _isAlreadyFriend = alreadyFriend;
      _isLoading = false;
    } catch (e, st) {
      if (_disposed) return;
      debugPrint('ProfilePageModel.loadProfile: $e\n$st');
      _profile = null;
      _isAlreadyFriend = false;
      _isLoading = false;
      _error = e.toString();
    }

    notifyListeners();
  }

  Future<FriendRequestResult> sendFriendRequest() async {
    final loadedProfile = _profile;

    if (loadedProfile == null) {
      return FriendRequestResult.noProfile();
    }
    if (isOwnProfile) {
      return FriendRequestResult.ownProfile();
    }
    if (_sendingFriendRequest) {
      return FriendRequestResult.alreadySending();
    }

    _sendingFriendRequest = true;
    notifyListeners();

    try {
      await friends.sendFriendRequest(loadedProfile);

      if (_disposed) return FriendRequestResult.disposed();

      _friendRequestSent = true;
      _sendingFriendRequest = false;
      notifyListeners();
      return FriendRequestResult.sent();
    } catch (error) {
      if (_disposed) return FriendRequestResult.disposed();

      _sendingFriendRequest = false;
      notifyListeners();
      return FriendRequestResult.failure(error);
    }
  }

  void replaceProfile(UserProfile updatedProfile) {
    _profile = updatedProfile;
    notifyListeners();
  }

  Future<void> signOut() => auth.signOut();

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

enum FriendRequestStatus {
  sent,
  noProfile,
  ownProfile,
  alreadySending,
  failure,
  disposed,
}

class FriendRequestResult {
  const FriendRequestResult._(this.status, [this.error]);

  final FriendRequestStatus status;
  final Object? error;

  bool get isSent => status == FriendRequestStatus.sent;

  factory FriendRequestResult.sent() {
    return const FriendRequestResult._(FriendRequestStatus.sent);
  }

  factory FriendRequestResult.noProfile() {
    return const FriendRequestResult._(FriendRequestStatus.noProfile);
  }

  factory FriendRequestResult.ownProfile() {
    return const FriendRequestResult._(FriendRequestStatus.ownProfile);
  }

  factory FriendRequestResult.alreadySending() {
    return const FriendRequestResult._(FriendRequestStatus.alreadySending);
  }

  factory FriendRequestResult.failure(Object error) {
    return FriendRequestResult._(FriendRequestStatus.failure, error);
  }

  factory FriendRequestResult.disposed() {
    return const FriendRequestResult._(FriendRequestStatus.disposed);
  }
}
