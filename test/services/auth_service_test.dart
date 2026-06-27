import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/supabase/supabase_auth_service.dart';

// Pretend versions of the two Supabase pieces we touch.
class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late _MockGoTrueClient gotrue; // the "auth" part of Supabase
  late _MockSupabaseClient client;
  late SupabaseAuthService auth;

  setUp(() {
    gotrue = _MockGoTrueClient();
    client = _MockSupabaseClient();
    // Whenever the code reads client.auth, hand back our fake auth.
    when(() => client.auth).thenReturn(gotrue);
    auth = SupabaseAuthService(client: client);
  });

  group('isSignedIn', () {
    test('false when there is no current session', () {
      when(() => gotrue.currentSession).thenReturn(null);
      expect(auth.isSignedIn(), isFalse);
    });

    test('true when there is a current session', () {
      when(() => gotrue.currentSession).thenReturn(_session);
      expect(auth.isSignedIn(), isTrue);
    });
  });

  group('getCurrentUserId', () {
    test('throws NotSignedInException when there is no current user', () {
      when(() => gotrue.currentUser).thenReturn(null);
      expect(auth.getCurrentUserId, throwsA(isA<NotSignedInException>()));
    });

    test('returns the user ID when there is a current user', () {
      when(() => gotrue.currentUser).thenReturn(_user);
      expect(auth.getCurrentUserId(), 'user-id');
    });
  });

  group('hasValidSession', () {
    test('false without calling getUser when there is no session', () async {
      when(() => gotrue.currentSession).thenReturn(null);

      final result = await auth.hasValidSession();

      expect(result, isFalse);
      verifyNever(() => gotrue.getUser());
    });

    test('true when getUser returns a user', () async {
      when(() => gotrue.currentSession).thenReturn(_session);
      when(
        () => gotrue.getUser(),
      ).thenAnswer((_) async => _userResponseWithUser);

      await expectLater(auth.hasValidSession(), completion(isTrue));
    });

    test('false when getUser returns no user', () async {
      when(() => gotrue.currentSession).thenReturn(_session);
      when(
        () => gotrue.getUser(),
      ).thenAnswer((_) async => _userResponseWithoutUser);

      await expectLater(auth.hasValidSession(), completion(isFalse));
    });

    test('false when getUser throws AuthException', () async {
      when(() => gotrue.currentSession).thenReturn(_session);
      when(
        () => gotrue.getUser(),
      ).thenThrow(const AuthException('expired session'));

      await expectLater(auth.hasValidSession(), completion(isFalse));
    });
  });
}

// Same minimal Session/User fixtures as before.
final _session = Session(
  accessToken: 'access-token',
  tokenType: 'bearer',
  user: _user,
);

final _user = User(
  id: 'user-id',
  appMetadata: const {},
  userMetadata: const {},
  aud: 'authenticated',
  createdAt: '2026-01-01T00:00:00.000Z',
);

final _userResponseWithUser = UserResponse.fromJson(_user.toJson());
final _userResponseWithoutUser = UserResponse.fromJson(const {});
