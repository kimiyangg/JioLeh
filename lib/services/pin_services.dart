import 'package:jio_leh/services/auth_services.dart';
import 'package:jio_leh/models/pinned_location.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class PinServices {
  late final AuthServices auth;

  // The Supabase client is shared from AuthServices so there is a single
  // source of truth for which client this app talks to.

  // This getter exists purely as a convenience alias so the method bodies can write
  // _supabase.from(...) instead of the noisier auth.client.from(...) 
  SupabaseClient get _supabase => auth.client;

  // Static table name for pinned locations in the database
  static const _tableName = 'pinned_locations';

  PinServices({AuthServices? auth}) {
    // If an AuthServices is provided (e.g., for testing), use it
    // otherwise, use the default instance.
    if (auth != null) {
      this.auth = auth;
    } else {
      this.auth = AuthServices();
    }
  }

  Future<void> savePinnedLocation(PinnedLocation pin) async {
    final userId = auth.getCurrentUserId();
    await _supabase.from(_tableName).insert(pin.toMap(userId));
  }

  Future<List<PinnedLocation>> loadPinnedLocations() async {
    final userId = auth.getCurrentUserId();

    final data = await _supabase
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return data.map(PinnedLocation.fromMap).toList();
  }
}
