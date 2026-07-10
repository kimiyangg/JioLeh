import 'package:jio_leh/models/leaderboard_entry.dart';
import 'package:jio_leh/models/point_transaction.dart';
import 'package:jio_leh/services/points_service.dart';

class FakePointsService extends PointsService {
  FakePointsService({this.leaderboard = const []});

  List<LeaderboardEntry> leaderboard;

  int awardPointsCalls = 0;
  PointReason? lastReason;
  String? lastReferenceId;
  int? lastCount;

  void Function()? lastLeaderboardOnChange;

  @override
  Future<void> awardPoints({
    required PointReason reason,
    String? referenceId,
    int count = 1,
  }) async {
    awardPointsCalls++;
    lastReason = reason;
    lastReferenceId = referenceId;
    lastCount = count;
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard(List<String> userIds) async {
    return leaderboard.where((e) => userIds.contains(e.profile.id)).toList();
  }

  @override
  void Function() subscribeToLeaderboard(void Function() onChange) {
    lastLeaderboardOnChange = onChange;
    return () {};
  }
}