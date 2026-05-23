import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  // Supabase client instance private to this service
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get currentUserId {
    return _supabase.auth.currentUser?.id;
  }

  bool isSignedIn() {
    return _supabase.auth.currentUser != null;
  }

  Future<String> signInIfNeeded() async {
    // Checks if a user is already signed in; if not, performs anonymous sign-in
    // returns the user ID
    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      return currentUser.id;
    }
    final response = await _supabase.auth.signInAnonymously();
    final user = response.user;
    if (user == null) {
      throw StateError('Anonymous sign-in failed');
    }
    return user.id;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
