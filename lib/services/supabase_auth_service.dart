import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/services/auth_service.dart';

/// The real [AuthService] used in production, backed by Supabase.
/// Write a sibling class if a new provider is needed in the future
class SupabaseAuthService extends AuthService {
  SupabaseAuthService({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  @override
  User? getCurrentUser() => _supabase.auth.currentUser;

  @override
  bool isSignedIn() => _supabase.auth.currentSession != null;

  @override
  Future<bool> hasValidSession() async {
    if (!isSignedIn()) return false;
    try {
      final response = await _supabase.auth.getUser();
      return response.user != null;
    } on AuthException {
      return false;
    }
  }

  @override
  Stream<AuthState> authStateChanges() => _supabase.auth.onAuthStateChange;

  @override
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

  @override
  Future<void> signOut() async => _supabase.auth.signOut();
}