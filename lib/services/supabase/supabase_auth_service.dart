import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
  Future<void> signInWithApple() async {
    final rawNonce = _supabase.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const SignInCancelledException();
      }
      rethrow;
    }

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException('Apple sign-in did not return an identity token.');
    }

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }



  @override
  Future<void> signOut() async => _supabase.auth.signOut();
}