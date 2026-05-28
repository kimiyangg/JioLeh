import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  String? getCurrentUserId() {
    return getCurrentUser()?.id;
  }

  String requireCurrentUserId() {
    final userId = getCurrentUserId();

    if (userId == null) {
      throw StateError('User must be signed in.');
    }

    return userId;
  }

  Session? getCurrentSession() {
    return _supabase.auth.currentSession;
  }

  Stream<AuthState> authStateChanges() {
    // The onAuthStateChange stream emits an event
    // whenever the authentication state changes (e.g., user signs in, signs out, or the session expires).
    return _supabase.auth.onAuthStateChange;
  }

  bool isSignedIn() {
    return getCurrentSession() != null;
  }

  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'com.gijios.jioleh://login-callback/',
      authScreenLaunchMode:
          kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
