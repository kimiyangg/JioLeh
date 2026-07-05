import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/models/jio_chat_message.dart';

void main() {
  group('JioChatMessage.fromMap', () {
    test('parses all fields from a full row', () {
      final message = JioChatMessage.fromMap(
        {
          'id': 'msg-1',
          'event_id': 'event-1',
          'sender_id': 'user-1',
          'sender_name': 'Kimi',
          'content': 'See you there!',
          'created_at': '2026-07-05T10:30:00.000Z',
        },
        imageUrl: 'https://example.com/photo.jpg',
      );

      expect(message.id, 'msg-1');
      expect(message.eventId, 'event-1');
      expect(message.senderId, 'user-1');
      expect(message.senderName, 'Kimi');
      expect(message.content, 'See you there!');
      expect(message.imageUrl, 'https://example.com/photo.jpg');
      expect(message.createdAt, DateTime.parse('2026-07-05T10:30:00.000Z'));
    });

    test('content is null when the map has no content key', () {
      final message = JioChatMessage.fromMap({
        'id': 'msg-1',
        'event_id': 'event-1',
        'sender_id': 'user-1',
        'sender_name': 'Kimi',
        'created_at': '2026-07-05T10:30:00.000Z',
      });

      expect(message.content, isNull);
    });

    test('imageUrl defaults to null when not passed in', () {
      final message = JioChatMessage.fromMap({
        'id': 'msg-1',
        'event_id': 'event-1',
        'sender_id': 'user-1',
        'sender_name': 'Kimi',
        'content': 'Hello',
        'created_at': '2026-07-05T10:30:00.000Z',
      });

      expect(message.imageUrl, isNull);
    });
  });

  group('hasImage', () {
    test('true when imageUrl is set', () {
      final message = JioChatMessage(
        id: 'msg-1',
        eventId: 'event-1',
        senderId: 'user-1',
        senderName: 'Kimi',
        imageUrl: 'https://example.com/photo.jpg',
        createdAt: DateTime(2026, 7, 5),
      );

      expect(message.hasImage, isTrue);
    });

    test('false when imageUrl is null', () {
      final message = JioChatMessage(
        id: 'msg-1',
        eventId: 'event-1',
        senderId: 'user-1',
        senderName: 'Kimi',
        createdAt: DateTime(2026, 7, 5),
      );

      expect(message.hasImage, isFalse);
    });
  });

  group('hasText', () {
    test('true when content is non-empty', () {
      final message = JioChatMessage(
        id: 'msg-1',
        eventId: 'event-1',
        senderId: 'user-1',
        senderName: 'Kimi',
        content: 'Hello',
        createdAt: DateTime(2026, 7, 5),
      );

      expect(message.hasText, isTrue);
    });

    test('false when content is null', () {
      final message = JioChatMessage(
        id: 'msg-1',
        eventId: 'event-1',
        senderId: 'user-1',
        senderName: 'Kimi',
        createdAt: DateTime(2026, 7, 5),
      );

      expect(message.hasText, isFalse);
    });

    test('false when content is an empty string', () {
      final message = JioChatMessage(
        id: 'msg-1',
        eventId: 'event-1',
        senderId: 'user-1',
        senderName: 'Kimi',
        content: '',
        createdAt: DateTime(2026, 7, 5),
      );

      expect(message.hasText, isFalse);
    });
  });
}
