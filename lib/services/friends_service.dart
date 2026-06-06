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
      friends.add(UserFriend(
        userProfile: UserProfile.fromMap(row['profiles']),
        status: FriendshipStatus.values.byName(row['status'])
      ));
    }

    for (final row in receivedFriends) {
      friends.add(UserFriend(
        userProfile: UserProfile.fromMap(row['profiles']),
        status: FriendshipStatus.values.byName(row['status'])
      ));
    }

    return friends;
  }

}