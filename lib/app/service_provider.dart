import 'package:flutter/widgets.dart';

import 'package:jio_leh/services/account_service.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/friends_service.dart';
import 'package:jio_leh/services/geocoding_service.dart';
import 'package:jio_leh/services/jio_chat_service.dart';
import 'package:jio_leh/services/location_service.dart';
import 'package:jio_leh/services/open_jio_service.dart';
import 'package:jio_leh/services/pin_service.dart';
import 'package:jio_leh/services/services.dart';

/// An [InheritedWidget] that provides access to application services throughout
/// the widget tree.
///
/// This allows for dependency injection, making it easier to swap real services
/// with fakes during testing by wrapping the app or a specific subtree in a
/// [ServiceProvider].
class ServiceProvider extends InheritedWidget {
  const ServiceProvider({
    super.key,
    AuthService? auth,
    AccountService? account,
    PinService? pins,
    LocationService? location,
    GeocodingService? geocoding,
    FriendsService? friends,
    OpenJioService? openJio,
    JioChatService? jioChat,
    required super.child,
  }) : _auth = auth,
       _account = account,
       _pins = pins,
       _location = location,
       _geocoding = geocoding,
       _friends = friends,
       _openJio = openJio,
       _jioChat = jioChat;

  final AuthService? _auth;
  final AccountService? _account;
  final PinService? _pins;
  final LocationService? _location;
  final GeocodingService? _geocoding;
  final FriendsService? _friends;
  final OpenJioService? _openJio;
  final JioChatService? _jioChat;

  AuthService get auth => _auth ?? Services.auth;
  AccountService get account => _account ?? Services.account;
  PinService get pins => _pins ?? Services.pins;
  LocationService get location => _location ?? Services.location;
  GeocodingService get geocoding => _geocoding ?? Services.geocoding;
  FriendsService get friends => _friends ?? Services.friends;
  OpenJioService get openJio => _openJio ?? Services.openJio;
  JioChatService get jioChat => _jioChat ?? Services.jioChat;

  /// Finds the nearest [ServiceProvider] above this widget in the widget tree.
  ///
  /// Child widgets use this helper to access shared services without passing
  /// them through every constructor. It returns `null` if no [ServiceProvider]
  /// is mounted above the given [context].
  static ServiceProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ServiceProvider>();
  }

  // Services are created once and never swapped, so reads never rebuild.
  @override
  bool updateShouldNotify(ServiceProvider oldWidget) => false;
}
