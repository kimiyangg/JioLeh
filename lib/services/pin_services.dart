import 'package:jio_leh/models/pinned_location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PinServices {
  final SupabaseClient supabase;

  PinServices(this.supabase);

  Future<String> signInIfNeeded() async {
    final currentUser = supabase.auth.currentUser;

    if (currentUser != null) {
      return currentUser.id;
    }

    final response = await supabase.auth.signInAnonymously();
    final user = response.user;

    if (user == null) {
    throw StateError('Anonymous sign-in failed');
    }

    return user.id;
  }
  

  Future<void> savePinnedLocation({
    required double latitude,
    required double longitude,
    required String name,
    required String emoji,
  }) async {
    final userId = await signInIfNeeded();

    await supabase.from('pinned_locations').insert({
      'user_id': userId,
      'name': name,
      'emoji': emoji,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<List<PinnedLocation>> loadPinnedLocations() async {
    final userId = await signInIfNeeded();

    final data = await supabase
        .from('pinned_locations')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return data
    .map((map) => PinnedLocation.fromMap(map))
    .toList();
  }
}
