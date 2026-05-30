import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/foundation.dart';

class AuthServices {
  late final SupabaseClient _supabase;

  AuthServices({SupabaseClient? supabase}) {
    // If a Supabase client is provided (e.g., for testing), use it
    // otherwise, use the default instance.
    if (supabase != null) {
      _supabase = supabase;
    } else {
      _supabase = Supabase.instance.client;
    }
  }

  // Exposes the underlying Supabase client so other services (e.g.
  // AccountServices, PinServices) share a single client instead of each
  // resolving their own.
  SupabaseClient get client => _supabase;

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
  
  Session? _getCurrentSession() {
    // Helper method to retrieve the current session from the Supabase client.
    return _supabase.auth.currentSession;
  }

  bool isSignedIn() {
    return _getCurrentSession() != null;
  }

  String getCurrentUserId() {
    // Retrieves the current user's ID,
    // throwing an error if no user is signed in.
    final userId = getCurrentUser()?.id;

    if (userId == null) {
      // StateError is used here to indicate that the application is in an unexpected state
      // (i.e., a user ID is required but not available).

      // TO-DO: Catch and handle this error in PinServices
      throw StateError('User must be signed in.');
    }

    return userId;
  }

  Stream<AuthState> authStateChanges() {
    // The onAuthStateChange stream emits an event
    // whenever the authentication state changes (e.g., user signs in, signs out, or the session expires).

    // Current use: determine whether to show the AuthPage or the MapPage in app.dart
    return _supabase.auth.onAuthStateChange;
  }

  Future<void> signInWithGoogle() async {
    // Initiates the Google sign-in flow using Supabase's authentication API.
    // On web, it will open a popup; on mobile, it will launch the external browser for authentication.
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
