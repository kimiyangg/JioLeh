import 'package:jio_leh/services/auth_services.dart';
import 'package:jio_leh/models/pinned_location.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class PinServices {
  final SupabaseClient supabase;
  final AuthServices auth;

  // Static table name for pinned locations in the database
  static const _tableName = 'pinned_locations';

  PinServices(this.supabase, this.auth);


  Future<void> savePinnedLocation(PinnedLocation pin) async {
    final userId = await auth.signInIfNeeded();
    await supabase.from(_tableName).insert(pin.toMap(userId));
  }

  Future<List<PinnedLocation>> loadPinnedLocations() async {
    final userId = await auth.signInIfNeeded();

    final data = await supabase
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return data.map(PinnedLocation.fromMap).toList();
  }
}
