class SuggestedPlace {
  final String placeId;
  final String name;
  final String? category;
  final double latitude;
  final double longitude;
  final double? avgFriendRating;
  final int friendCount;
  final int? recencyDays;
  final int pinCount;
  final bool categoryMatch;
  final double score;

  const SuggestedPlace({
    required this.placeId,
    required this.name,
    this.category,
    required this.latitude,
    required this.longitude,
    this.avgFriendRating,
    required this.friendCount,
    this.recencyDays,
    required this.pinCount,
    required this.categoryMatch,
    required this.score,
  });

  factory SuggestedPlace.fromMap(
    Map<String, dynamic> map, {
    required double score,
  }) {
    return SuggestedPlace(
      placeId: map['place_id'] as String,
      name: map['name'] as String? ?? 'Unnamed place',
      category: map['category'] as String?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      avgFriendRating: (map['avg_friend_rating'] as num?)?.toDouble(),
      friendCount: map['friend_count'] as int? ?? 0,
      recencyDays: map['recency_days'] as int?,
      pinCount: map['pin_count'] as int? ?? 0,
      categoryMatch: map['category_match'] as bool? ?? false,
      score: score,
    );
  }
}
