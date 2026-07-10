import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/models/user_profile.dart';

/// The contract for user friendship operations. The whole app depends on this,
/// so the real Supabase service can be swapped for a fake in tests.
/// Write a sibling class if a new backend is needed in the future.
abstract class FriendsService {
  /// Fetches the list of friends for the current user, including their
  /// profiles and friendship statuses.
  ///
  /// Returns a list of [UserFriend] objects representing each friend and their
  /// status and direction.
  Future<List<UserFriend>> getUserFriends();

  /// Sends a friend request from the current user to the specified [toUser].
  ///
  /// Throws a [FriendAlreadyExists] exception if a friend request already
  /// exists between the users.
  Future<void> sendFriendRequest(UserProfile toUser);

  /// Accepts a pending friend request from the specified [fromUser].
  ///
  /// Throws a [FriendsRequestNotFound] exception if there is no pending friend
  /// request from the specified user.
  Future<void> acceptFriendRequest(UserProfile fromUser);

  /// Rejects a pending friend request from the specified [fromUser].
  ///
  /// Throws a [FriendsRequestNotFound] exception if there is no pending friend
  /// request from the specified user.
  Future<void> rejectFriendRequest(UserProfile fromUser);

  /// Removes an existing friend relationship with the specified [friend].
  ///
  /// Throws a [FriendNotFound] exception if there is no existing friendship
  /// with the specified user.
  Future<void> removeFriend(UserProfile friend);

  /// Subscribes to incoming friend requests for the current user and calls
  /// [onChange] for each. Returns a function that cancels the subscription.
  void Function() subscribeToFriendRequests(void Function() onChange);
}

/// Base class for all friends-related exceptions
class FriendsException implements Exception {
  final String message;
  const FriendsException(this.message);
  @override
  String toString() => message;
}

/// Exception thrown when a friend request already exists between the users.
class FriendAlreadyExists extends FriendsException {
  const FriendAlreadyExists() : super('Friend request already exists.');
}

/// Exception thrown when a friend request is not found.
class FriendsRequestNotFound extends FriendsException {
  const FriendsRequestNotFound()
    : super('No pending friend request from this user.');
}

/// Exception thrown when attempting to fetch a friend that does not exist.
class FriendNotFound extends FriendsException {
  const FriendNotFound() : super('No existing friendship with this user.');
}
