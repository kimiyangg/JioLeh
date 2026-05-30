import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/services/auth_services.dart';

class AccountServices {
  final SupabaseClient supabase;
  final AuthServices auth;

  // Static table name for user profiles in the database
  static const _tableName = 'profiles';

  AccountServices(this.supabase, this.auth);

  Future<bool> profileExists() async {
    // Returns whether the current user has a profile row
    // i.e. whether they have completed onboarding
    final userId = auth.getCurrentUserId();

    final row = await supabase
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

    await supabase.from(_tableName).insert({
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

    final profile = await supabase
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
