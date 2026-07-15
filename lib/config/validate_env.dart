import 'map_env.dart';
import 'place_env.dart';
import 'supabase_env.dart';
import 'vision_env.dart';

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

    if (PlaceEnv.googlePlacesApiKey.isEmpty) {
      missingValues.add('GOOGLE_PLACES_API_KEY');
    }

    if (VisionEnv.googleVisionApiKey.isEmpty) {
      missingValues.add('GOOGLE_VISION_API_KEY');
    }

    if (missingValues.isNotEmpty) {
      throw StateError(
        'Missing dart-define values: ${missingValues.join(', ')}',
      );
    }
  }
}
