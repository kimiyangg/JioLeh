import 'package:supabase_flutter/supabase_flutter.dart';

/// The contract for authentication. The whole app depends on this,
/// so the real Supabase service can be swapped for a fake in tests.
abstract class AuthService {
  User? getCurrentUser();
  bool isSignedIn();
  Future<bool> hasValidSession();
  Stream<AuthState> authStateChanges();
  Future<void> signInWithGoogle();
  Future<void> signOut();

  // Derived helpers — shared by every implementation, so they live here once.
  String? getCurrentUserEmail() => getCurrentUser()?.email;

  String? getCurrentUserName() {
    // ?. to indicate currentUser might be null
    final metadata = getCurrentUser()?.userMetadata;
    return metadata?['full_name'] as String? ?? metadata?['name'] as String?;
  }

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