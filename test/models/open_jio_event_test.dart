import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/models/open_jio_event.dart';
import 'package:jio_leh/models/user_friend.dart';
import 'package:jio_leh/models/user_profile.dart';

UserFriend _friend(String displayName) {
  return UserFriend(
    userProfile: UserProfile(
      id: 'id-$displayName',
      username: displayName.toLowerCase(),
      displayName: displayName,
      birthday: null,
      bio: null,
      avatarUrl: null,
    ),
    status: FriendshipStatus.accepted,
    direction: FriendDirection.incoming,
  );
}

void main() {
  group('OpenJioEvent.fromMap', () {
    test('parses required fields from a full row', () {
      final event = OpenJioEvent.fromMap({
        'id': 'event-1',
        'date_time': '2026-07-05T18:00:00.000Z',
        'caption': 'Dinner at Marina Bay',
        'location_name': 'Marina Bay Sands',
        'user_id': 'user-1',
      });

      expect(event.id, 'event-1');
      expect(event.dateTime, DateTime.parse('2026-07-05T18:00:00.000Z'));
      expect(event.caption, 'Dinner at Marina Bay');
      expect(event.locationName, 'Marina Bay Sands');
      expect(event.senderId, 'user-1');
    });

    test('parses place_id when present', () {
      final event = OpenJioEvent.fromMap({
        'id': 'event-1',
        'date_time': '2026-07-05T18:00:00.000Z',
        'caption': 'Dinner',
        'location_name': 'Somewhere',
        'place_id': 'place-1',
      });

      expect(event.placeId, 'place-1');
    });

    test('placeId is null when the map has no place_id', () {
      final event = OpenJioEvent.fromMap({
        'id': 'event-1',
        'date_time': '2026-07-05T18:00:00.000Z',
        'caption': 'Dinner',
        'location_name': 'Somewhere',
      });

      expect(event.placeId, isNull);
    });

    test('senderId is null when the map has no user_id', () {
      final event = OpenJioEvent.fromMap({
        'id': 'event-1',
        'date_time': '2026-07-05T18:00:00.000Z',
        'caption': 'Dinner',
        'location_name': 'Somewhere',
      });

      expect(event.senderId, isNull);
    });

    test('invitedFriends defaults to an empty list when not provided', () {
      final event = OpenJioEvent.fromMap({
        'id': 'event-1',
        'date_time': '2026-07-05T18:00:00.000Z',
        'caption': 'Dinner',
        'location_name': 'Somewhere',
      });

      expect(event.invitedFriends, isEmpty);
    });

    test('senderName and inviteStatus default to null when not provided', () {
      final event = OpenJioEvent.fromMap({
        'id': 'event-1',
        'date_time': '2026-07-05T18:00:00.000Z',
        'caption': 'Dinner',
        'location_name': 'Somewhere',
      });

      expect(event.senderName, isNull);
      expect(event.inviteStatus, isNull);
    });

    test('stores an explicit senderName, invitedFriends, and status', () {
      final friends = [_friend('Alex')];
      final event = OpenJioEvent.fromMap(
        {
          'id': 'event-1',
          'date_time': '2026-07-05T18:00:00.000Z',
          'caption': 'Dinner',
          'location_name': 'Somewhere',
        },
        invitedFriends: friends,
        senderName: 'Kimi',
        status: InviteStatus.accepted,
      );

      expect(event.invitedFriends, friends);
      expect(event.senderName, 'Kimi');
      expect(event.inviteStatus, InviteStatus.accepted);
    });
  });

  group('friendNames', () {
    test("joins multiple invited friends' display names with a comma", () {
      final event = OpenJioEvent(
        invitedFriends: [_friend('Alex'), _friend('Sam')],
        dateTime: DateTime(2026, 7, 5),
        caption: 'Dinner',
        locationName: 'Somewhere',
      );

      expect(event.friendNames, 'Alex, Sam');
    });

    test('returns an empty string when there are no invited friends', () {
      final event = OpenJioEvent(
        invitedFriends: const [],
        dateTime: DateTime(2026, 7, 5),
        caption: 'Dinner',
        locationName: 'Somewhere',
      );

      expect(event.friendNames, '');
    });
  });

  group('toMap', () {
    test('only includes date_time, caption, and location_name', () {
      final event = OpenJioEvent(
        id: 'event-1',
        invitedFriends: [_friend('Alex')],
        dateTime: DateTime(2026, 7, 5, 18, 0),
        caption: 'Dinner',
        locationName: 'Somewhere',
        senderId: 'user-1',
        senderName: 'Kimi',
        inviteStatus: InviteStatus.accepted,
      );

      expect(event.toMap(), {
        'date_time': DateTime(2026, 7, 5, 18, 0).toIso8601String(),
        'caption': 'Dinner',
        'location_name': 'Somewhere',
      });
    });

    test('includes place_id when placeId is set', () {
      final event = OpenJioEvent(
        invitedFriends: [_friend('Alex')],
        dateTime: DateTime(2026, 7, 5, 18, 0),
        caption: 'Dinner',
        locationName: 'Somewhere',
        placeId: 'place-1',
      );

      expect(event.toMap(), {
        'date_time': DateTime(2026, 7, 5, 18, 0).toIso8601String(),
        'caption': 'Dinner',
        'location_name': 'Somewhere',
        'place_id': 'place-1',
      });
    });
  });
}
