import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/models/suggested_place.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/suggested_places_service.dart';

/// The real [SuggestedPlacesService] used in production, backed by Supabase.
///
/// [_score] is a hand-picked formula for now. Once `suggested_place_impressions`
/// has a few weeks of real click/save data, retrain offline and swap the
/// constants below for the learned logistic-regression weights — nothing
/// else in this class needs to change.
class SupabaseSuggestedPlacesService extends SuggestedPlacesService {
  SupabaseSuggestedPlacesService({
    required SupabaseClient client,
    required this.auth,
  }) : _supabase = client;

  final AuthService auth;
  final SupabaseClient _supabase;

  // Friend ratings this many days old contribute half as much as a fresh one.
  static const _recencyHalfLifeDays = 14.0;

  // Bonus added when a place matches the user's most-pinned category.
  static const _categoryMatchBonus = 0.5;

  @override
  Future<List<SuggestedPlace>> getSuggestedPlaces({int limit = 10}) async {
    final userId = auth.getCurrentUserId();

    final rows = await _supabase.rpc(
      'get_friend_recommended_places',
      params: {'p_user_id': userId},
    );

    final candidates =
        (rows as List<dynamic>).cast<Map<String, dynamic>>().map((row) {
          return SuggestedPlace.fromMap(row, score: _score(row));
        }).toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    final top = candidates.take(limit).toList();
    if (top.isEmpty) return top;

    await _supabase.from('suggested_place_impressions').insert([
      for (var i = 0; i < top.length; i++)
        {
          'user_id': userId,
          'place_id': top[i].placeId,
          'avg_friend_rating': top[i].avgFriendRating,
          'friend_count': top[i].friendCount,
          'recency_days': top[i].recencyDays,
          'pin_count': top[i].pinCount,
          'category_match': top[i].categoryMatch,
          'rank_position': i + 1,
        },
    ]);

    return top;
  }

  @override
  Future<void> recordSuggestionClicked(String placeId) async {
    await _supabase
        .from('suggested_place_impressions')
        .update({'clicked_at': DateTime.now().toIso8601String()})
        .eq('user_id', auth.getCurrentUserId())
        .eq('place_id', placeId);
  }

  @override
  Future<void> recordSuggestionSaved(String placeId) async {
    await _supabase
        .from('suggested_place_impressions')
        .update({'saved_at': DateTime.now().toIso8601String()})
        .eq('user_id', auth.getCurrentUserId())
        .eq('place_id', placeId);
  }

  double _score(Map<String, dynamic> row) {
    final avgRating = (row['avg_friend_rating'] as num?)?.toDouble() ?? 0;
    final recencyDays = (row['recency_days'] as num?)?.toDouble() ?? 999;
    final categoryMatch = row['category_match'] as bool? ?? false;

    final recencyWeight = exp(-recencyDays / _recencyHalfLifeDays);
    final categoryBonus = categoryMatch ? _categoryMatchBonus : 0.0;

    return avgRating * recencyWeight + categoryBonus;
  }
}
