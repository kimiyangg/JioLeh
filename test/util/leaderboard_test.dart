import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/util/leaderboard.dart';

UserProfile _profile(String id, String name) => UserProfile(
  id: id,
  username: name.toLowerCase(),
  displayName: name,
  birthday: null,
  bio: null,
  avatarUrl: null,
);

void main() {
  group('buildLeaderboard', () {
    test('sorts by points descending', () {
      final result = buildLeaderboard(
        [_profile('1', 'Alice'), _profile('2', 'Bob')],
        {'1': 10, '2': 20},
      );

      expect(result.map((e) => e.profile.id), ['2', '1']);
    });

    test('defaults a profile with no transactions to 0 points', () {
      final result = buildLeaderboard([_profile('1', 'Alice')], {});

      expect(result.single.points, 0);
    });

    test('breaks ties by display name', () {
      final result = buildLeaderboard(
        [_profile('1', 'Bob'), _profile('2', 'Alice')],
        {'1': 5, '2': 5},
      );

      expect(result.map((e) => e.profile.displayName), ['Alice', 'Bob']);
    });
  });
}