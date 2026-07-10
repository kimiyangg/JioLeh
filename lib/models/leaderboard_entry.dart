import 'package:jio_leh/models/user_profile.dart';

// A single row on the leaderboard: a profile plus their total points.
class LeaderboardEntry {
  final UserProfile profile;
  final int points;

  const LeaderboardEntry({required this.profile, required this.points});
}
