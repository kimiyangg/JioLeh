import 'package:supabase_flutter/supabase_flutter.dart';

/// The contract for authentication. The whole app depends on this,
/// so the real Supabase service can be swapped for a fake in tests.
abstract class AuthService {

  /// Returns the signed-in user, or null if no one is signed in.
  User? getCurrentUser();

  /// True if there's a signed-in user right now (no network check).
  bool isSignedIn();

  /// Checks with the server whether the current session is still valid.
  Future<bool> hasValidSession();

  /// A stream that emits whenever the sign-in state changes.
  Stream<AuthState> authStateChanges();

  /// Starts the Google sign-in flow.
  Future<void> signInWithGoogle();

  /// Starts the Apple sign-in flow.
  Future<void> signInWithApple();

  /// Signs the current user out.
  Future<void> signOut();

  // Derived helpers — shared by every implementation, so they live here once.
  /// The signed-in user's email, or null if no one is signed in.
  String? getCurrentUserEmail() => getCurrentUser()?.email;

  /// The signed-in user's display name, or null if no one is signed in.
  String? getCurrentUserName() {
    // ?. to indicate currentUser might be null
    final metadata = getCurrentUser()?.userMetadata;
    return metadata?['full_name'] as String? ?? metadata?['name'] as String?;
  }

  /// The signed-in user's id, or throws [NotSignedInException] if no one is signed in.
  String getCurrentUserId() {
    final userId = getCurrentUser()?.id;
    if (userId == null) {
      throw const NotSignedInException();
    }
    return userId;
  }
}

/// Base class for authentication-related exceptions raised by this app.
class AuthServiceException implements Exception {
  final String message;
  const AuthServiceException(this.message);
  @override
  String toString() => message;
}

/// Exception thrown when an operation requires a signed-in user.
class NotSignedInException extends AuthServiceException {
  const NotSignedInException() : super('User must be signed in.');
}

/// Exception thrown when the user cancels a sign-in flow themselves.
class SignInCancelledException extends AuthServiceException {
  const SignInCancelledException() : super('Sign-in was cancelled.');
}