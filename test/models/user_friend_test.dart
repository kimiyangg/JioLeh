import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/models/user_friend.dart';

void main() {
  group('UserFriend.fromMap', () {
    test('parses a full row loaded from the database', () {
      final map = {
        'profiles': {
          'id': '06627568-abc7-4619-adb4-4f122eb56c02',
          'username': 'djehrtjd',
          'display_name': 'Kimi Yang',
          'birthday': DateTime.parse('1990-01-01').toIso8601String(),
          'bio' : 'I am KIMI!!!!!!!!!!!',
        },
        'status': 'accepted',
        'direction': 'incoming',
      };

      final userFriend = UserFriend.fromMap(map, FriendDirection.incoming);

      expect(userFriend.userProfile.id, '06627568-abc7-4619-adb4-4f122eb56c02');
      expect(userFriend.userProfile.username, 'djehrtjd');
      expect(userFriend.userProfile.displayName, 'Kimi Yang');
      expect(userFriend.userProfile.birthday, DateTime.parse('1990-01-01'));
      expect(userFriend.userProfile.bio, 'I am KIMI!!!!!!!!!!!');
      expect(userFriend.status, FriendshipStatus.accepted);
      expect(userFriend.direction, FriendDirection.incoming);
    });

    test('throws ArgumentError if status is invalid', () {
      final map = {
        'profiles': {
          'id': '06627568-abc7-4619-adb4-4f122eb56c02',
          'username': 'djehrtjd',
          'display_name': 'Kimi Yang',
          'birthday': DateTime.parse('1990-01-01').toIso8601String(),
          'bio' : 'I am KIMI!!!!!!!!!!!',
        },
        'status': 'invalid_status',
        'direction': 'incoming',
      };

      expect(() => UserFriend.fromMap(map, FriendDirection.incoming), throwsA(isA<ArgumentError>()));
    });
  });
}

