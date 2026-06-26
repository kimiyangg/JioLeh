import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/models/jio_chat_message.dart';

/// The contract for Open Jio group-chat operations. The whole app depends on
/// this, so the real Supabase service can be swapped for a fake in tests.
/// Write a sibling class if a new backend is needed in the future.
abstract class JioChatService {
  /// Loads all messages for [eventId], oldest first.
  Future<List<JioChatMessage>> loadMessages(String eventId);

  /// Sends a text message to [eventId]. No-op if [text] is blank.
  Future<void> sendText(String eventId, String text);

  /// Uploads [photo] and sends it as a photo message to [eventId].
  Future<void> sendPhoto(String eventId, XFile photo);

  /// Listens for new messages on [eventId], calling [onMessage] for each.
  ///
  /// Returns a function that cancels the subscription when invoked.
  void Function() subscribeToMessages(
    String eventId,
    void Function(JioChatMessage message) onMessage,
  );
}
