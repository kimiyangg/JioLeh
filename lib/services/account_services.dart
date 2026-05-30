import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/services/auth_services.dart';

class AccountServices {
  late final AuthServices auth;

  // The Supabase client is shared from AuthServices so there is a single
  // source of truth for which client this app talks to.

  // This getter exists purely as a convenience alias so the method bodies can write
  // _supabase.from(...) instead of the noisier auth.client.from(...) 
  SupabaseClient get _supabase => auth.client;

  // Static table name for user profiles in the database
  static const _tableName = 'profiles';

  AccountServices({AuthServices? auth}) {
    // If an AuthServices is provided (e.g., for testing), use it
    // otherwise, use the default instance.
    if (auth != null) {
      this.auth = auth;
    } else {
      this.auth = AuthServices();
    }
  }

  Future<bool> profileExists() async {
    // Returns whether the current user has a profile row
    // i.e. whether they have completed onboarding
    final userId = auth.getCurrentUserId();

    final row = await _supabase
        .from(_tableName)
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    return row != null;
  }

  Future<void> createProfile({
    required String username,
    required String displayName,
    DateTime? birthday,
  }) async {
    // Inserts the current user's profile row
    final userId = auth.getCurrentUserId();

    await _supabase.from(_tableName).insert({
      'id': userId,
      'username': username,
      'display_name': displayName,
      if (birthday != null)
        'birthday': birthday.toIso8601String().split('T').first,
    });
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    // Retrieves the current user's profile row from the 'profiles' table.
    final userId = auth.getCurrentUserId();

    final profile = await _supabase
        .from(_tableName)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (profile == null) {
      throw StateError('Profile not found for user ID: $userId');
    }

    return profile;
  }
}
