import 'package:flutter_test/flutter_test.dart';
import 'package:jio_leh/config/validate_env.dart';

void main() {
  group('ValidateEnv.validateEnvironment', () {
    test('throws StateError when required dart-defines are missing', () {

      expect(
        // The test will fail if any of the required environment variables are missing.
        ValidateEnv.validateEnvironment,
        // Default `flutter test` provides no --dart-define, so every value is empty.
        // We expect a StateError to be thrown due to missing environment variables.
        throwsA(isA<StateError>()),
      );
    });

    test('error message lists every missing key', () {
      try {
        ValidateEnv.validateEnvironment();
        fail('Expected a StateError to be thrown');
      } on StateError catch (e) {
        // The error message should mention every required environment variable that is missing.
        expect(e.message, contains('MAPBOX_ACCESS_TOKEN'));
        expect(e.message, contains('SUPABASE_URL'));
        expect(e.message, contains('SUPABASE_ANON_KEY'));
        expect(e.message, contains('MAPBOX_STYLE_URI'));
      }
    });
  });
}
