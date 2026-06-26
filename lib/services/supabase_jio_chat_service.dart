import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/models/jio_chat_message.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/jio_chat_service.dart';

/// The real [JioChatService] used in production, backed by Supabase.
/// Write a sibling class if a new backend is needed in the future.
class SupabaseJioChatService extends JioChatService {
  final AuthService auth;
  final SupabaseClient _client;

  static const _table = 'jio_chat_messages';
  static const _bucket = 'chat-photos';

  // The sender's display name rarely changes during a session, so look it up
  // once and reuse it for every message they send.
  String? _cachedSenderName;

  SupabaseJioChatService({required SupabaseClient client, required this.auth})
      : _client = client;

  @override
  Future<List<JioChatMessage>> loadMessages(String eventId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('event_id', eventId)
        .order('created_at', ascending: true);

    return rows.map((row) => _fromRow(row)).toList();
  }

  @override
  Future<void> sendText(String eventId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return; // never insert an empty message

    await _client.from(_table).insert({
      'event_id': eventId,
      'sender_id': auth.getCurrentUserId(),
      'sender_name': await _resolveSenderName(),
      'content': trimmed,
    });
  }

  @override
  Future<void> sendPhoto(String eventId, XFile photo) async {
    // Upload the file first, then store its path in the message row.
    final path = await _uploadPhoto(eventId, photo);

    await _client.from(_table).insert({
      'event_id': eventId,
      'sender_id': auth.getCurrentUserId(),
      'sender_name': await _resolveSenderName(),
      'image_path': path,
    });
  }

  @override
  void Function() subscribeToMessages(
    String eventId,
    void Function(JioChatMessage message) onMessage,
  ) {
    final channel = _client
        .channel('jio_chat_$eventId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'event_id',
            value: eventId,
          ),
          callback: (payload) => onMessage(_fromRow(payload.newRecord)),
        )
        .subscribe();

    return () {
      channel.unsubscribe();
    };
  }

  /// Uploads [photo] to chat-photos under the event's folder and returns its
  /// storage path (NOT a URL — we store the path and build the URL on read).
  Future<String> _uploadPhoto(String eventId, XFile photo) async {
    final extension = photo.path.split('.').last.toLowerCase();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final path = '$eventId/$fileName';
    final bytes = await photo.readAsBytes();

    await _client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: photo.mimeType),
        );

    return path;
  }

  /// Turns a raw DB row into a [JioChatMessage], converting the stored
  /// image_path into a public URL the UI can show.
  JioChatMessage _fromRow(Map<String, dynamic> row) {
    final imagePath = row['image_path'] as String?;
    final imageUrl = imagePath == null
        ? null
        : _client.storage.from(_bucket).getPublicUrl(imagePath);

    return JioChatMessage.fromMap(row, imageUrl: imageUrl);
  }

  /// Looks up (and caches) the current user's display name for stamping onto
  /// messages, matching how the rest of the app reads `profiles.display_name`.
  Future<String> _resolveSenderName() async {
    if (_cachedSenderName != null) return _cachedSenderName!;

    final userId = auth.getCurrentUserId();
    final row = await _client
        .from('profiles')
        .select('display_name')
        .eq('id', userId)
        .maybeSingle();

    _cachedSenderName = (row?['display_name'] as String?) ?? 'Someone';
    return _cachedSenderName!;
  }
}
