import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AuthService', () {
    group('isSignedIn', () {
      test('returns false when there is no current session', () {
        final auth = AuthService(currentSession: () => null);

        expect(auth.isSignedIn(), isFalse);
      });

      test('returns true when there is a current session', () {
        final auth = AuthService(currentSession: () => _session);

        expect(auth.isSignedIn(), isTrue);
      });
    });

    group('getCurrentUserId', () {
      test('throws StateError when there is no current user', () {
        final auth = AuthService(currentUser: () => null);

        expect(auth.getCurrentUserId, throwsStateError);
      });

      test('returns the current user ID when there is a current user', () {
        final auth = AuthService(currentUser: () => _user);

        expect(auth.getCurrentUserId(), 'user-id');
      });
    });

    group('hasValidSession', () {
      test(
        'returns false without calling getUser when there is no session',
        () async {
          var getUserCalls = 0;
          final auth = AuthService(
            currentSession: () => null,
            getUser: () async {
              getUserCalls++;
              return _userResponseWithUser;
            },
          );

          final result = await auth.hasValidSession();

          expect(result, isFalse);
          expect(getUserCalls, 0);
        },
      );

      test('returns true when getUser returns a user', () async {
        final auth = AuthService(
          currentSession: () => _session,
          getUser: () async => _userResponseWithUser,
        );

        await expectLater(auth.hasValidSession(), completion(isTrue));
      });

      test('returns false when getUser returns no user', () async {
        final auth = AuthService(
          currentSession: () => _session,
          getUser: () async => _userResponseWithoutUser,
        );

        await expectLater(auth.hasValidSession(), completion(isFalse));
      });

      test(
        'returns false without signing out when getUser throws AuthException',
        () async {
          var signOutCalls = 0;
          final auth = AuthService(
            currentSession: () => _session,
            getUser: () async => throw const AuthException('expired session'),
            signOut: () async {
              signOutCalls++;
            },
          );

          final result = await auth.hasValidSession();

          expect(result, isFalse);
          expect(signOutCalls, 0);
        },
      );
    });
  });
}

// Minimal Supabase auth model fixture: these are the required Session/User
// constructor fields from gotrue, and isSignedIn only needs a non-null session.
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
  createdAt: DateTime(2026).toIso8601String(),
);

final _userResponseWithUser = UserResponse.fromJson(_user.toJson());
final _userResponseWithoutUser = UserResponse.fromJson(const {});
