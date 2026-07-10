import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/models/point_transaction.dart';
import 'package:jio_leh/models/leaderboard_entry.dart';
import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/points_service.dart';
import 'package:jio_leh/util/leaderboard.dart';

/// The real [PointsService] used in production, backed by Supabase.
class SupabasePointsService extends PointsService {
  SupabasePointsService({required SupabaseClient client, required this.auth})
    : _supabase = client;

  final AuthService auth;
  final SupabaseClient _supabase;

  @override
  Future<void> awardPoints({
    required PointReason reason,
    String? referenceId,
    int count = 1,
  }) async {
    if (count < 1) return;

    final userId = auth.getCurrentUserId();
    final rows = List.generate(
      count,
      (_) => {
        'user_id': userId,
        'amount': reason.points,
        'reason': reason.name,
        'reference_id': referenceId,
      },
    );

    await _supabase.from('point_transactions').insert(rows);
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    final profileRows = await _supabase
        .from('profiles')
        .select()
        .inFilter('id', userIds);

    final pointRows = await _supabase
        .from('user_points')
        .select('user_id, points')
        .inFilter('user_id', userIds);

    final pointsById = <String, int>{
      for (final row in pointRows)
        row['user_id'] as String: row['points'] as int,
    };

    return buildLeaderboard(
      profileRows.map(UserProfile.fromMap).toList(),
      pointsById,
    );
  }
}