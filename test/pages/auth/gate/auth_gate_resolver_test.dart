import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/pages/auth/gate/auth_gate_resolver.dart';

void main() {
  group('resolveAuthGateState', () {
    test('resolves to signedOut when there is no local session', () async {
      var hasValidSessionCalls = 0;
      var profileExistsCalls = 0;

      final result = await resolveAuthGateState(
        isSignedIn: () => false,
        hasValidSession: () async {
          hasValidSessionCalls++;
          return false;
        },
        profileExists: () async {
          profileExistsCalls++;
          return false;
        },
      );

      expect(result, AuthGateResult.signedOut);
      expect(hasValidSessionCalls, 0);
      expect(profileExistsCalls, 0);
    });

    test(
      'stale deleted account resolves to signedOut instead of onboarding',
      () async {
        var hasValidSessionCalls = 0;
        var profileExistsCalls = 0;

        final result = await resolveAuthGateState(
          isSignedIn: () => true,
          hasValidSession: () async {
            hasValidSessionCalls++;
            return false;
          },
          profileExists: () async {
            profileExistsCalls++;
            return false;
          },
        );

        expect(result, AuthGateResult.signedOut);
        expect(hasValidSessionCalls, 1);
        expect(profileExistsCalls, 0);
      },
    );

    test('valid session without profile resolves to needsOnboarding', () async {
      var profileExistsCalls = 0;

      final result = await resolveAuthGateState(
        isSignedIn: () => true,
        hasValidSession: () async => true,
        profileExists: () async {
          profileExistsCalls++;
          return false;
        },
      );

      expect(result, AuthGateResult.needsOnboarding);
      expect(profileExistsCalls, 1);
    });

    test('valid session with profile resolves to ready', () async {
      var profileExistsCalls = 0;

      final result = await resolveAuthGateState(
        isSignedIn: () => true,
        hasValidSession: () async => true,
        profileExists: () async {
          profileExistsCalls++;
          return true;
        },
      );

      expect(result, AuthGateResult.ready);
      expect(profileExistsCalls, 1);
    });
  });
}
