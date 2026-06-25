/// One message in an Open Jio group chat.
///
/// A message always has either [content] (text) or [imageUrl] (a photo) — the
/// database guarantees it can't have neither.
class JioChatMessage {
  const JioChatMessage({
    required this.id,
    required this.eventId,
    required this.senderId,
    required this.senderName,
    this.content,
    this.imageUrl,
    required this.createdAt,
  });

  /// Builds a message from a database row. The row stores an `image_path`
  /// (a storage path); the service converts it to a public [imageUrl] before
  /// calling this, so the UI can use it directly.
  factory JioChatMessage.fromMap(
    Map<String, dynamic> map, {
    String? imageUrl,
  }) {
    return JioChatMessage(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      senderId: map['sender_id'] as String,
      senderName: map['sender_name'] as String,
      content: map['content'] as String?,
      imageUrl: imageUrl,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  final String id;
  final String eventId;
  final String senderId;
  final String senderName;
  final String? content;   // text, or null for a photo-only message
  final String? imageUrl;  // public photo URL, or null for a text-only message
  final DateTime createdAt;

  bool get hasImage => imageUrl != null;
  bool get hasText => content != null && content!.isNotEmpty;
}
