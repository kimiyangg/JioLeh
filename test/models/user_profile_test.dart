import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/models/user_profile.dart';

void main() {
  group('UserProfile.fromMap', () {
    test('parses a full row loaded from the database', () {
      final map = {
        'id': '06627568-abc7-4619-adb4-4f122eb56c02',
        'username': 'djehrtjd',
        'display_name': 'Kimi Yang',
        'birthday': DateTime.parse('1990-01-01').toIso8601String(),
        'bio' : 'I am KIMI!!!!!!!!!!!',
      };

      final user = UserProfile.fromMap(map);

      expect(user.id, '06627568-abc7-4619-adb4-4f122eb56c02');
      expect(user.username, 'djehrtjd');
      expect(user.displayName, 'Kimi Yang');
      expect(user.birthday, DateTime.parse('1990-01-01'));
      expect(user.bio, 'I am KIMI!!!!!!!!!!!');
    });

    test('allows null birthday and bio', () {
      final map = {
        'id': '06627568-abc7-4619-adb4-4f122eb56c02',
        'username': 'djehrtjd',
        'display_name': 'Kimi Yang',
        'birthday': null,
        'bio' : null,
      };

      final user = UserProfile.fromMap(map);

      expect(user.birthday, isNull);
      expect(user.bio, isNull);
    });

    test('throws if required fields are missing', () {
      final map = {
        'id': '06627568-abc7-4619-adb4-4f122eb56c02',
        // 'username' is missing
        'display_name': 'Kimi Yang',
        'birthday': null,
        'bio' : null,
      };

      expect(() => UserProfile.fromMap(map), throwsA(isA<TypeError>()));
    });
  });
}
