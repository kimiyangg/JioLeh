class UserInsertedPin {
  // This draft is created before anything is saved to Supabase.
  // It stores what the user typed/selected in the add-pin sheet.
  final double latitude;
  final double longitude;

  // The real/formal place name, saved into places.name.
  final String formalName;

  // The user's optional nickname for this place.
  // If this is blank, custom_name should stay null in user_pins.
  final String? customName;

  final String emoji;
  final int? rating;
  final String? review;
  final bool isPrivate;

  const UserInsertedPin({
    required this.latitude,
    required this.longitude,
    required this.formalName,
    this.customName,
    required this.emoji,
    this.rating,
    this.review,
    required this.isPrivate,
  });

  // Creates the row for the places table.
  // This is shared place data, not user-specific pin data.
  Map<String, dynamic> placeToMap(String userId) {
    final trimmedFormalName = formalName.trim();

    // Formal name is required because places.name is the shared place label.
    if (trimmedFormalName.isEmpty) {
      throw ArgumentError.value(
        formalName,
        'formalName',
        'Formal place name cannot be blank',
      );
    }

    return {
      'name': trimmedFormalName,
      'latitude': latitude,
      'longitude': longitude,
      'created_by': userId,
      'source': 'user',
      'status': 'pending',
    };
  }

  Map<String, dynamic> pinToMap(String userId, String placeId) {
    // Trimming keeps the DB clean and prevents weird display bugs later
    final trimmedCustomName = customName?.trim();
    final trimmedReview = review?.trim();

    return {
      'user_id': userId,
      'place_id': placeId,

      // Keep custom_name null when the user did not customise it.
      // The UI can fall back to places.name when displaying.
      'custom_name': trimmedCustomName == null || trimmedCustomName.isEmpty
          ? null
          : trimmedCustomName,

      'emoji': emoji,
      'ratings': rating,
      'is_private': isPrivate,

      // Blank review means no review.
      'reviews': trimmedReview == null || trimmedReview.isEmpty
          ? null
          : trimmedReview,
    };
  }
}
