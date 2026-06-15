import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/foundation.dart';

class AuthService {
  // Fields used for authentication and database operations.
  // This can be provided via the constructor for testing purposes.
  AuthService({
    SupabaseClient? client,
    Session? Function()? currentSession,
    User? Function()? currentUser,
    Future<UserResponse> Function()? getUser,
    Future<void> Function()? signOut,
  }) : _client = client,
       _currentSession = currentSession,
       _currentUser = currentUser,
       _getUser = getUser,
       _signOut = signOut;

  final SupabaseClient? _client;
  final Session? Function()? _currentSession;
  final User? Function()? _currentUser;
  final Future<UserResponse> Function()? _getUser;
  final Future<void> Function()? _signOut;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  SupabaseClient get client => _supabase;

  User? getCurrentUser() {
    if (_currentUser != null) {
      return _currentUser();
    }

    return _supabase.auth.currentUser;
  }

  Session? _getCurrentSession() {
    // Helper method to retrieve the current session from the Supabase client.
    if (_currentSession != null) {
      return _currentSession();
    }

    return _supabase.auth.currentSession;
  }

  bool isSignedIn() {
    return _getCurrentSession() != null;
  }

  /// Function to check if the current session is still valid by attempting to fetch the user data.
  ///
  /// Returns true if the session is valid and the user is authenticated, false otherwise.
  Future<bool> hasValidSession() async {
    if (!isSignedIn()) {
      return false;
    }

    try {
      final response = await (_getUser != null
          ? _getUser()
          : _supabase.auth.getUser());
      return response.user != null;
    } on AuthException {
      await signOut();
      return false;
    }
  }

  String getCurrentUserId() {
    // Retrieves the current user's ID,
    // throwing an error if no user is signed in.
    final userId = getCurrentUser()?.id;

    if (userId == null) {
      // StateError is used here to indicate that the application is in an unexpected state
      // (i.e., a user ID is required but not available).

      // TO-DO: Catch and handle this error in PinService
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
    // On web, it will open a popup; on mobile, it will launch the system browser
    // (Safari on iOS / the default browser on Android), which redirects back to the
    // app via the com.gijios.jioleh:// deep link once authentication completes.
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'com.gijios.jioleh://login-callback/',
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() async {
    if (_signOut != null) {
      // TODO: mv this to the caller instead, making this a pure query function
      // await _signOut();
      return;
    }

    await _supabase.auth.signOut();
  }
}
