import 'auth_service.dart';
import 'supabase/supabase_auth_service.dart';
import 'package:jio_leh/services/points_service.dart';
import 'package:jio_leh/services/supabase/supabase_points_service.dart';
import 'pin_service.dart';
import 'supabase/supabase_pin_service.dart';
import 'location_service.dart';
import 'geocoding_service.dart';
import 'account_service.dart';
import 'supabase/supabase_account_service.dart';
import 'friends_service.dart';
import 'supabase/supabase_friends_service.dart';
import 'place_service.dart';
import 'google_place_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jio_leh/services/open_jio_service.dart';
import 'package:jio_leh/services/supabase/supabase_open_jio_service.dart';
import 'package:jio_leh/services/jio_chat_service.dart';
import 'package:jio_leh/services/supabase/supabase_jio_chat_service.dart';


/// A singleton class that provides access to all application services.
///
/// This class centralizes service instantiation and ensures that dependencies,
/// such as the [SupabaseClient] and [AuthService], are shared across services.
class Services {
  static final _client = Supabase.instance.client;

  // Pick the real worker here, ONCE. The type stays AuthService, so the rest
  // of the app never mentions Supabase.
  static final AuthService auth = SupabaseAuthService(client: _client);

  static final PointsService points = SupabasePointsService(
    client: _client,
    auth: auth,
  );

  static final PinService pins = SupabasePinService(
    client: _client,
    auth: auth,
    points: points,
  );

  static final location = LocationService();

  static final geocoding = GeocodingService();

  static final OpenJioService openJio = SupabaseOpenJioService(
    client: _client,
    auth: auth,
    points: points,
  );

  static final JioChatService jioChat = SupabaseJioChatService(
    client: _client,
    auth: auth,
  );

  static final AccountService account = SupabaseAccountService(
    client: _client,
    auth: auth,
  );

  static final FriendsService friends = SupabaseFriendsService(
    client: _client,
    auth: auth,
  );

  static final PlaceService places = GooglePlaceService();


}
