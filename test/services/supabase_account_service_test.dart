import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/services/supabase/supabase_account_service.dart';

void main() {
  group('decideAccountInsertAction', () {
    test('duplicate on a generated username -> retry', () {
      expect(
        decideAccountInsertAction(errorCode: '23505', usernameGiven: false),
        InsertAction.retry,
      );
    });

    test('duplicate on a user-chosen username -> name taken', () {
      expect(
        decideAccountInsertAction(errorCode: '23505', usernameGiven: true),
        InsertAction.nameTaken,
      );
    });

    test('a different error code -> unknown error (user-chosen name)', () {
      expect(
        decideAccountInsertAction(errorCode: '23503', usernameGiven: true),
        InsertAction.unknownError,
      );
    });

    test('a different error code -> unknown error (generated name)', () {
      expect(
        decideAccountInsertAction(errorCode: '42P01', usernameGiven: false),
        InsertAction.unknownError,
      );
    });

    test('a null error code -> unknown error', () {
      expect(
        decideAccountInsertAction(errorCode: null, usernameGiven: false),
        InsertAction.unknownError,
      );
    });
  });
}
