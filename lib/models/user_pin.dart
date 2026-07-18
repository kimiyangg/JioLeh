enum PinSentiment { positive, negative, mixed }

class UserPin {
  final String? id;
  final String userId;
  final String? placeId;
  final String? customName;
  final String emoji;
  final int? rating;
  final String? review;
  final List<String> photoPaths;
  final List<String> aiTags;
  final bool isPrivate;
  final String? sentimentLabel;
  final double? sentimentScore;

  const UserPin({
    this.id,
    required this.userId,
    this.placeId,
    this.customName,
    required this.emoji,
    this.rating,
    this.review,
    this.photoPaths = const [],
    this.aiTags = const [],
    this.isPrivate = false,
    this.sentimentLabel,
    this.sentimentScore,
  });

  factory UserPin.fromMap(Map<String, dynamic> map) {
    final rawPhotoPaths = map['photo_paths'] as List<dynamic>?;
    final rawAiTags = map['ai_tags'] as List<dynamic>?;

    return UserPin(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      placeId: map['place_id'] as String?,
      customName: map['custom_name'] as String?,
      emoji: map['emoji'] as String? ?? 'pin',
      rating: map['ratings'] as int?,
      review: map['reviews'] as String?,
      photoPaths:
          rawPhotoPaths?.map((path) => path.toString()).toList() ?? const [],
      aiTags:
          rawAiTags?.map((tag) => tag.toString()).toList() ?? const [],
      isPrivate: map['is_private'] as bool? ?? false,
      sentimentLabel: map['sentiment_label'] as String?,
      sentimentScore: (map['sentiment_score'] as num?)?.toDouble(),
    );
  }

  static const double sentimentConfidenceThreshold = 0.8;

  PinSentiment? get sentiment {
    if (sentimentLabel == null || sentimentScore == null) return null;
    if (sentimentScore! < sentimentConfidenceThreshold) {
      return PinSentiment.mixed;
    }
    if (sentimentLabel == 'POSITIVE') return PinSentiment.positive;
    return PinSentiment.negative;
  }
}
