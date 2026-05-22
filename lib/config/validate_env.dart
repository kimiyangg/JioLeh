import 'map_env.dart';
import 'supabase_env.dart';

// Validates all required dart-define values are present and throws a StateError if any are missing
class ValidateEnv {
  static void validateEnvironment() {
    final missingValues = [];

    if (MapEnv.mapboxAccessToken.isEmpty) {
      missingValues.add('MAPBOX_ACCESS_TOKEN');
    }

    if (SupabaseEnv.supabaseUrl.isEmpty) {
      missingValues.add('SUPABASE_URL');
    }

    if (SupabaseEnv.supabaseAnonKey.isEmpty) {
      missingValues.add('SUPABASE_ANON_KEY');
    }

    if (MapEnv.mapboxStyleUri.isEmpty) {
      missingValues.add('MAPBOX_STYLE_URI');
    }

    if (missingValues.isNotEmpty) {
      throw StateError(
        'Missing dart-define values: ${missingValues.join(', ')}',
      );
    }
  }

}