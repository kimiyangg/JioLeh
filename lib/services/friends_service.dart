import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/services/auth_service.dart';

import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/models/user_profile.dart';

/// Service class responsible for managing user friendships,
/// including fetching friends and their statuses.
class FriendsService {
  final AuthService auth;

  // The Supabase client is shared from AuthService so there is a single
  // source of truth for which client this app talks to.

  // This getter exists purely as a convenience alias so the method bodies can write
  // _supabase.from(...) instead of the noisier auth.client.from(...)
  SupabaseClient get _supabase => auth.client;

  static const _tableName = 'friendships';

  FriendsService(this.auth);

  /// Fetches the list of friends for the current user, including their profiles and friendship statuses.
  /// 
  /// Returns a list of [UserFriend] objects representing each friend and their status.
  Future<List<UserFriend>> getUserFriends() async {

    final userId = auth.getCurrentUserId();

    final friends = <UserFriend>[];

    // .select('profiles!requestor_id(*), status') means:
    // - Join the 'profiles' table where 'requestor_id' matches the 'id' in 'profiles'

    // Case: current user is the requester (i.e., they sent the friend request)
    final sentFriends = await _supabase
        .from(_tableName)
        .select('profiles!addressee_id(*), status')
        .eq('requester_id', userId);

    // Case: current user is the addressee (i.e., they received the friend request)
    final receivedFriends = await _supabase
        .from(_tableName)
        .select('profiles!requester_id(*), status')
        .eq('addressee_id', userId);
    
    for (final row in sentFriends) {
      friends.add(UserFriend.fromMap(row, FriendDirection.outgoing));
    }

    for (final row in receivedFriends) {
      friends.add(UserFriend.fromMap(row, FriendDirection.incoming));
    }

    return friends;
  }
  
  /// Sends a friend request from the current user to the specified [toUser].
  /// 
  /// Returns a Future that completes when the friend request is successfully sent.
  /// 
  /// Throws a [FriendAlreadyExists] exception if a friend request already exists between the users
  Future<void> sendFriendRequest(UserProfile toUser) async {
    final userId = auth.getCurrentUserId();
    try {
      await _supabase.from(_tableName).insert({
        'requester_id': userId,
        'addressee_id': toUser.id,
        'status': FriendshipStatus.pending.name,
      });
    } on PostgrestException catch (e) {
      // PostgrestException with code '23505' indicates a unique constraint violation
      // https://www.postgresql.org/docs/current/errcodes-appendix.html for more details
      if (e.code == '23505') {
        throw const FriendAlreadyExists();
      }
      // For any other PostgrestException, we rethrow it to be handled by the caller.
      rethrow;
    }
  }

  /// Accepts a pending friend request from the specified [fromUser].
  /// 
  /// Returns a Future that completes when the friend request is successfully accepted.
  /// 
  /// Throws a [FriendsRequestNotFound] exception if there is no pending friend request from the specified user.
  Future<void> acceptFriendRequest(UserProfile fromUser) async {
    final userId = auth.getCurrentUserId();
    final updated = await _supabase
      .from(_tableName)
      .update({'status': FriendshipStatus.accepted.name,})
      .eq('requester_id', fromUser.id)
      .eq('addressee_id', userId)
      .eq('status', FriendshipStatus.pending.name)
      .select();
    
    if (updated.isEmpty) {
      throw const FriendsRequestNotFound();
    }
  }

  /// Rejects a pending friend request from the specified [fromUser].
  /// 
  /// Returns a Future that completes when the friend request is successfully rejected.
  /// 
  /// Throws a [FriendsRequestNotFound] exception if there is no pending friend request from the specified user.
  Future<void> rejectFriendRequest(UserProfile fromUser) async {
    final userId = auth.getCurrentUserId();
    final deleted = await _supabase
      .from(_tableName)
      .delete()
      .eq('requester_id', fromUser.id)
      .eq('addressee_id', userId)
      .eq('status', FriendshipStatus.pending.name)
      .select();
    
    if (deleted.isEmpty) {
      throw const FriendsRequestNotFound();
    }
  }

  /// Removes an existing friend relationship with the specified [friend].
  /// 
  /// Returns a Future that completes when the friend relationship is successfully removed.
  /// 
  /// Throws a [FriendNotFound] exception if there is no existing friendship with the specified user.
  Future<void> removeFriend(UserProfile friend) async {
    final userId = auth.getCurrentUserId();

    // Case: current user sent the original request
    final orgSent = await _supabase
        .from(_tableName)
        .delete()
        .eq('status', FriendshipStatus.accepted.name)
        .eq('requester_id', userId)
        .eq('addressee_id', friend.id)
        .select();

    // Case: the friend sent the original request
    final orgReceived = await _supabase
        .from(_tableName)
        .delete()
        .eq('status', FriendshipStatus.accepted.name)
        .eq('requester_id', friend.id)
        .eq('addressee_id', userId)
        .select();
    
    if (orgSent.isEmpty && orgReceived.isEmpty) {
      throw const FriendNotFound();
    }
  }
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
  const FriendAlreadyExists()
    : super('Friend request already exists.');
}

/// Exception thrown when a friend request is not found.
class FriendsRequestNotFound extends FriendsException {
  const FriendsRequestNotFound()
    : super('No pending friend request from this user.');
}

/// Exception thrown when attempting to fetch a friend that does not exist.
class FriendNotFound extends FriendsException {
  const FriendNotFound()
    : super('No existing friendship with this user.');
}