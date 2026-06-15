import 'auth_service.dart';
import 'pin_service.dart';
import 'location_service.dart';
import 'geocoding_service.dart';
import 'account_service.dart';
import 'friends_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class Services {
  static final _client = Supabase.instance.client;

  static final auth = AuthService(client: _client);

  static final pins = PinService(auth);
  static final location = LocationService();
  static final geocoding = GeocodingService();
  static final account = AccountService(auth);
  static final friends = FriendsService(auth);
}