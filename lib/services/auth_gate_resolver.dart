enum AuthGateResult { signedOut, needsOnboarding, ready }

/// Resolves which authentication state the app should route to.
///
/// Returns an [AuthGateResult] based on the user's session and profile state.
Future<AuthGateResult> resolveAuthGateState({
  required bool Function() isSignedIn,
  required Future<bool> Function() hasValidSession,
  required Future<bool> Function() profileExists,
}) async {
  if (!isSignedIn()) {
    return AuthGateResult.signedOut;
  }

  final validSession = await hasValidSession();
  if (!validSession) {
    return AuthGateResult.signedOut;
  }

  final hasProfile = await profileExists();
  return hasProfile ? AuthGateResult.ready : AuthGateResult.needsOnboarding;
}
