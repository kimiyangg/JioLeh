import 'package:flutter/widgets.dart';

import 'package:jio_leh/services/suggested_places_service.dart';
import 'package:jio_leh/services/account_service.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/services/friends_service.dart';
import 'package:jio_leh/services/geocoding_service.dart';
import 'package:jio_leh/services/jio_chat_service.dart';
import 'package:jio_leh/services/location_service.dart';
import 'package:jio_leh/services/open_jio_service.dart';
import 'package:jio_leh/services/points_service.dart';
import 'package:jio_leh/services/pin_service.dart';
import 'package:jio_leh/services/fog_service.dart';
import 'package:jio_leh/services/place_service.dart';
import 'package:jio_leh/services/services.dart';
import 'package:jio_leh/services/photo_tagging_service.dart';   // ADD near other imports

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
    PhotoTaggingService? photoTagging,
    FogService? fog,
    LocationService? location,
    GeocodingService? geocoding,
    PlaceService? places,
    FriendsService? friends,
    OpenJioService? openJio,
    JioChatService? jioChat,
    PointsService? points,
    SuggestedPlacesService? suggestedPlaces,
  
    required super.child,
  }) : _auth = auth,
       _account = account,
       _pins = pins,
       _photoTagging = photoTagging,
       _fog = fog,
       _location = location,
       _geocoding = geocoding,
       _places = places,
       _friends = friends,
       _openJio = openJio,
       _jioChat = jioChat,
       _points = points,
       _suggestedPlaces = suggestedPlaces;

  final AuthService? _auth;
  final AccountService? _account;
  final PinService? _pins;
  final FogService? _fog;
  final LocationService? _location;
  final GeocodingService? _geocoding;
  final PlaceService? _places;
  final FriendsService? _friends;
  final OpenJioService? _openJio;
  final JioChatService? _jioChat;
  final PointsService? _points;
  final PhotoTaggingService? _photoTagging;
  final SuggestedPlacesService? _suggestedPlaces;
  
  AuthService get auth => _auth ?? Services.auth;
  AccountService get account => _account ?? Services.account;
  PinService get pins => _pins ?? Services.pins;
  PhotoTaggingService get photoTagging => _photoTagging ?? Services.photoTagging;
  FogService get fog => _fog ?? Services.fog;
  PointsService get points => _points ?? Services.points;
  SuggestedPlacesService get suggestedPlaces => _suggestedPlaces ?? Services.suggestedPlaces;
  LocationService get location => _location ?? Services.location;
  GeocodingService get geocoding => _geocoding ?? Services.geocoding;
  PlaceService get places => _places ?? Services.places;
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
