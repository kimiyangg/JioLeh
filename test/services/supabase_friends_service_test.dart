import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/services/supabase/supabase_friends_service.dart';

void main() {
  group('decideFriendInsertAction', () {
    test('a duplicate (23505) means the friendship already exists', () {
      expect(
        decideFriendInsertAction(errorCode: '23505'),
        FriendInsertAction.alreadyExists,
      );
    });

    test('any other error code is an unknown error', () {
      expect(
        decideFriendInsertAction(errorCode: '23503'),
        FriendInsertAction.unknownError,
      );
    });

    test('a null error code is an unknown error', () {
      expect(
        decideFriendInsertAction(errorCode: null),
        FriendInsertAction.unknownError,
      );
    });
  });
}
