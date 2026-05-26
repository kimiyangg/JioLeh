// Model class representing a pinned location with its details
class PinnedLocation {
  // Null for drafts (not yet saved); set by Supabase on insert.
  final String? id;
  final double latitude;
  final double longitude;
  final String name;
  final String emoji;

  const PinnedLocation({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.emoji,
  });

  factory PinnedLocation.fromMap(Map<String, dynamic> map) {
    return PinnedLocation(
      id:        map['id'] as String?,
      latitude:  (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      name:      map['name'] as String,
      emoji:     map['emoji'] as String,
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id':   userId,
      'name':      name,
      'emoji':     emoji,
      'latitude':  latitude,
      'longitude': longitude,
    };
  }
}