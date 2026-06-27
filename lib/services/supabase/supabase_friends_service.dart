import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/friends_service.dart';

import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/models/user_profile.dart';

/// The real [FriendsService] used in production, backed by Supabase.
/// Write a sibling class if a new backend is needed in the future.
class SupabaseFriendsService extends FriendsService {
  final AuthService auth;
  final SupabaseClient _supabase;

  static const _tableName = 'friendships';

  // `required this.auth` stores the injected AuthService in the auth field.
  SupabaseFriendsService({required SupabaseClient client, required this.auth})
    : _supabase = client;

  @override
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

  @override
  Future<void> sendFriendRequest(UserProfile toUser) async {
    final userId = auth.getCurrentUserId();
    try {
      await _supabase.from(_tableName).insert({
        'requester_id': userId,
        'addressee_id': toUser.id,
        'status': FriendshipStatus.pending.name,
      });
    } on PostgrestException catch (e) {
      // The 23505 -> "already exists" decision lives in [decideFriendInsertAction]
      // so it can be unit-tested without a database.
      if (decideFriendInsertAction(errorCode: e.code) ==
          FriendInsertAction.alreadyExists) {
        throw const FriendAlreadyExists();
      }
      // Any other PostgrestException is unexpected — rethrow for the caller.
      rethrow;
    }
  }

  @override
  Future<void> acceptFriendRequest(UserProfile fromUser) async {
    final userId = auth.getCurrentUserId();
    final updated = await _supabase
        .from(_tableName)
        .update({'status': FriendshipStatus.accepted.name})
        .eq('requester_id', fromUser.id)
        .eq('addressee_id', userId)
        .eq('status', FriendshipStatus.pending.name)
        .select();

    if (updated.isEmpty) {
      throw const FriendsRequestNotFound();
    }
  }

  @override
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

  @override
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

/// What [SupabaseFriendsService.sendFriendRequest] should do when the insert fails.
enum FriendInsertAction { alreadyExists, unknownError }

/// Decides what a failed friend-request insert means, from the Postgres [errorCode]
/// 23505 (a unique-constraint violation) means the friendship already exists
/// anything else is rethrown
FriendInsertAction decideFriendInsertAction({required String? errorCode}) {
  const duplicateCode = '23505';
  return errorCode == duplicateCode
      ? FriendInsertAction.alreadyExists
      : FriendInsertAction.unknownError;
}
