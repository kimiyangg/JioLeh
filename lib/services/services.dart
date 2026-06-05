import 'auth_service.dart';
import 'pin_service.dart';
import 'location_service.dart';
import 'geocoding_service.dart';
import 'account_service.dart';

class Services {
  static final auth = AuthService();
  static final pins = PinService(auth);
  static final location = LocationService();
  static final geocoding = GeocodingService();
  static final account = AccountService(auth);
}