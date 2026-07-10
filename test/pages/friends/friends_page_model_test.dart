import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/models/leaderboard_entry.dart';
import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/pages/friends/friends_page_model.dart';

import '../../services/fakes/fake_account_service.dart';
import '../../services/fakes/fake_auth_service.dart';
import '../../services/fakes/fake_friends_service.dart';
import '../../services/fakes/fake_points_service.dart';

UserProfile _profile(String id, String name) => UserProfile(
      id: id,
      username: name,
      displayName: name,
      birthday: null,
      bio: null,
      avatarUrl: null,
    );

UserFriend _accepted(String id, String name) => UserFriend(
      userProfile: _profile(id, name),
      status: FriendshipStatus.accepted,
      direction: FriendDirection.outgoing,
    );

final _currentUser = User(
  id: 'me',
  appMetadata: const {},
  userMetadata: const {},
  aud: 'authenticated',
  createdAt: '2026-01-01T00:00:00.000Z',
);

FriendsPageModel _buildModel({
  FakeFriendsService? friends,
  FakePointsService? points,
}) {
  return FriendsPageModel(
    friends: friends ?? FakeFriendsService(),
    account: FakeAccountService(),
    auth: FakeAuthService(user: _currentUser, signedIn: true),
    points: points ?? FakePointsService(),
  );
}

void main() {
  test('start loads the friend list', () async {
    final friends = FakeFriendsService(friends: [_accepted('a', 'Alice')]);
    final model = _buildModel(friends: friends);

    model.start();
    await pumpEventQueue();

    expect(model.isLoading, false);
    expect(model.acceptedFriends.length, 1);
  });

  test('firing the friend-request signal refetches the friend list', () async {
    final friends = FakeFriendsService(friends: []);
    final model = _buildModel(friends: friends);

    model.start();
    await pumpEventQueue();
    expect(model.acceptedFriends, isEmpty);

    // A new friend appears on the backend, then the realtime signal fires.
    friends.friends = [_accepted('a', 'Alice')];
    friends.lastFriendRequestOnChange!();
    await pumpEventQueue();

    expect(model.acceptedFriends.length, 1);
  });

  test('firing the leaderboard signal refetches the leaderboard', () async {
    final points = FakePointsService(leaderboard: const []);
    final model = _buildModel(points: points);

    model.start();
    await pumpEventQueue();
    expect(model.leaderboard, isEmpty);

    // Points get awarded on the backend, then the realtime signal fires.
    points.leaderboard = [
      LeaderboardEntry(profile: _profile('me', 'Me'), points: 5),
    ];
    points.lastLeaderboardOnChange!();
    await pumpEventQueue();

    expect(model.leaderboard.length, 1);
    expect(model.leaderboard.first.points, 5);
  });
}
