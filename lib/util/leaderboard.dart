import 'package:jio_leh/models/leaderboard_entry.dart';
import 'package:jio_leh/models/user_profile.dart';

/// Combines [profiles] with their point totals from [pointsById] and sorts
/// by points descending, breaking ties by display name. A profile missing
/// from [pointsById] defaults to 0 points (no transactions yet).
List<LeaderboardEntry> buildLeaderboard(
  List<UserProfile> profiles,
  Map<String, int> pointsById,
) {
  final entries = profiles
      .map(
        (profile) => LeaderboardEntry(
          profile: profile,
          points: pointsById[profile.id] ?? 0,
        ),
      )
      .toList();

  entries.sort((a, b) {
    final byPoints = b.points.compareTo(a.points);
    return byPoints != 0
        ? byPoints
        : a.profile.displayName.compareTo(b.profile.displayName);
  });

  return entries;
}