// Model class representing a pinned location with its details
class PinnedLocation {
  // The id is nullable because the same class represents a pin in two different life stages
  // and the id only exists in one of them, cuz id is assigned when written into database
  // 1. Before saving (client-side draft): no id yet
  // 2. After loading from the database: id is present
  final String? id;
  final double latitude;
  final double longitude;
  final String name;
  final String emoji;
  final int rating;
  final String? review;
  final List<String> photoPaths;

  const PinnedLocation({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.emoji,
    this.rating = 0,
    this.review = '',
    this.photoPaths = const [],
  });

  factory PinnedLocation.fromMap(Map<String, dynamic> map) {

    final rawPhotoPaths = map['photo_paths'] as List<dynamic>?;

    return PinnedLocation(
      id:        map['id'] as String?,
      latitude:  (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      name:      map['name'] as String,
      emoji:     map['emoji'] as String,
      rating: map['rating'] as int? ?? 0,
      review: map['review'] as String? ?? '',
      photoPaths:
        rawPhotoPaths?.map((path) => path.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id':   userId,
      'name':      name,
      'emoji':     emoji,
      'latitude':  latitude,
      'longitude': longitude,
      'rating': rating,
      'review': review,
      'photo_paths': photoPaths,
    };
  }
}