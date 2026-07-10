import 'package:jio_leh/models/leaderboard_entry.dart';
import 'package:jio_leh/models/point_transaction.dart';

/// The contract for point-award/leaderboard operations. The whole app depends
/// on this, so the real Supabase service can be swapped for a fake in tests.
abstract class PointsService {
  /// Awards the current user [count] transactions of [reason] (one row each,
  /// inserted in a single batch), optionally tagged with the id of the
  /// pin/event that earned it. [count] defaults to 1.
  Future<void> awardPoints({
    required PointReason reason,
    String? referenceId,
    int count = 1,
  });

  /// Fetches profiles + total points for [userIds], sorted by points
  /// descending (ties broken by display name). Users with no transactions
  /// yet are included with 0 points.
  Future<List<LeaderboardEntry>> getLeaderboard(List<String> userIds);

  /// Subscribes to any change in awarded points and calls [onChange] for each.
  /// Returns a function that cancels the subscription.
  void Function() subscribeToLeaderboard(void Function() onChange);
}