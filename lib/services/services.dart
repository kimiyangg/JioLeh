import 'auth_service.dart';
import 'supabase_auth_service.dart';
import 'pin_service.dart';
import 'location_service.dart';
import 'geocoding_service.dart';
import 'account_service.dart';
import 'supabase_account_service.dart';
import 'friends_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

/// A singleton class that provides access to all application services.
///
/// This class centralizes service instantiation and ensures that dependencies,
/// such as the [SupabaseClient] and [AuthService], are shared across services.
class Services {
  static final _client = Supabase.instance.client;

  // Pick the real worker here, ONCE. The type stays AuthService, so the rest
  // of the app never mentions Supabase.
  static final AuthService auth = SupabaseAuthService(client: _client);

  static final pins = PinService(client: _client, auth: auth);
  static final location = LocationService();
  static final geocoding = GeocodingService();
  static final AccountService account = SupabaseAccountService(
    client: _client,
    auth: auth,
  );
  static final friends = FriendsService(client: _client, auth: auth);
}
