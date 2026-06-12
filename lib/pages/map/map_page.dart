import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:jio_leh/config/map_env.dart';

import 'package:jio_leh/models/pinned_location.dart';

import 'package:jio_leh/pages/map/widgets/location_permission_dialog.dart';
import 'package:jio_leh/pages/map/widgets/current_area_bar.dart';
import 'package:jio_leh/pages/map/widgets/map_toolbar.dart';
import 'package:jio_leh/pages/map/widgets/location_customize_sheet.dart';
import 'package:jio_leh/pages/map/widgets/pin_type_picker.dart';

import 'package:jio_leh/pages/map/renders/map_pins.dart';

import 'package:jio_leh/pages/profile_page.dart';
import 'package:jio_leh/pages/friends_page.dart';

import 'package:jio_leh/services/services.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  // Services are resolved from the shared composition root (Services) so the
  // whole app uses a single AuthService — and therefore a single Supabase
  // client — instead of each page constructing its own.
  final auth = Services.auth;
  final _locationServicePins = Services.pins;
  final _geocoding = Services.geocoding;
  final _locationService = Services.location;

  // Map state and controls
  MapboxMap? _map;
  MapPins? _pins; 
  ViewportState? _initialViewport;

  // User location state and controls
  geo.Position? _currentPosition;

  bool _isLoadingLocation = true;

  // AreaName state and controls
  String _currentLocationName = 'Fetching location...';

  // Pins state and controls
  List<PinnedLocation> _pinnedLocations = [];

  @override
  void initState() {
    super.initState();
    _booting();
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }

  Future<void> _booting() async {
    // Main boot sequence to initialize location, map, and pins
    await _reloadPins();
    await _startLocationTracking();
  }

  // Map Helper Methods
  Future<void> _enableMapboxLocationComponent() async {
    if (_map == null) {
      return; // _map only assigned aft onMapCreated runs. this prevent crash
    }
    await _map!.location.updateSettings(
      // access and update location component settings
      LocationComponentSettings(
        // how user location marker shld behave
        enabled: true, // current loc can be seen
        pulsingEnabled: true, // pulsing animation ard user loc
        showAccuracyRing: true, // show GPS accuracy area
        puckBearingEnabled: true,
      ), // the ring/puck rotates when the user rotates (changes wrt bearing)
    );
  }

  Future<void> _initMapStyleSettings() async {
    if (_map == null) return;

    _map!.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    // Position the compass above the recenter button
    // (which is at bottom left with some margin)
    _map!.compass.updateSettings(
      CompassSettings(
        position: OrnamentPosition.BOTTOM_LEFT,
        marginLeft: 10,
        marginBottom: 30,
      ),
    );
  }

  Future<void> _moveCameraToPos(geo.Position position) async {
    if (_map == null) return; // prevent crash if method called too early
    await _map!.easeTo(
      // easeTo means the camera moves smoothly to current pos
      CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
        zoom: 15,
        bearing: 0,
        pitch: 60,
      ), // stay constant w earlier settings:
      // 15 zoom == street lvl, 0 bearing == north facing, 60 pitch == 3D view
      MapAnimationOptions(
        duration: 1000,
        startDelay: 0,
      ), // animate movement over 1000 millisec
    );
  }

  // Location Helper Methods
  Future<void> _startLocationTracking() async {
    // Fetches the user's current location and starts real-time tracking.
    // On failure, surfaces a dialog so the user can retry or open settings.
    try {
      final position = await _locationService.getCurrentLocation();
      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
        _initialViewport = CameraViewportState(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: 15,
          bearing: 0,
          pitch: 60,
        );
      });

      _updateLocationName(position);
      await _locationService.startLocationTracking(
        onLocationUpdate: _onLocationUpdate,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingLocation = false);
      await _showLocationErrorDialog(e);
    }
  }

  void _onLocationUpdate(geo.Position position) {
    _currentPosition = position;
    _updateLocationName(position);
  }

  Future<void> _recenterMap() async {
    if (_currentPosition == null) return;
    await _moveCameraToPos(_currentPosition!);
  }

  Future<void> _showLocationErrorDialog(Object error) async {
    await showLocationErrorDialog(
      context: context,
      error: error,
      locationService: _locationService,
      onRetry: () => _startLocationTracking(),
    );
  }

  // Area Name Helper Methods
  Future<void> _updateLocationName(geo.Position position) async {
    _geocoding
        .fetchAreaName(
          latitude: position.latitude,
          longitude: position.longitude,
        )
        .then((name) {
          if (!mounted) return;
          setState(() => _currentLocationName = name);
        });
  }

  // Pin Helper Methods
  Future<void> _reloadPins() async {
    final pins = await _locationServicePins.loadPinnedLocations();
    if (!mounted) return;
    setState(() => _pinnedLocations = pins);
    await _pins?.render(_pinnedLocations);
  }

  Future<void> _addPin() async {
    // function runs when user press add pin button
    final selectedType =
        await showPinTypePicker(context); // page comes up, wait for user to tap
    if (selectedType == null) return; // if nvr choose, return nth

    if (!mounted) return; // stops if page not active

    final customization = await showLocationCustomizeSheet(context, selectedType);

    if (!mounted) return; // in case user left page while sheet open

    if (customization == null) return;
    
    final position = _currentPosition; // save current location for pinning

    if (position == null) return; // stops if location unknown

    await _locationServicePins.savePinnedLocation(
      PinnedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        name: customization.name, // if user close page early, return ''
        // else, return wtv he typed in
        emoji: selectedType.emoji,
        rating: customization.rating,
        review: customization.review,
      ),
    ); // still save the emoji

    await _reloadPins();
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            viewport: _initialViewport,
            styleUri: MapEnv.mapboxStyleUri,
            onMapCreated: (controller) async {
              _map = controller;
              _pins = MapPins(controller);  

              await _initMapStyleSettings();
              await _enableMapboxLocationComponent();
              await _pins!.render(_pinnedLocations);

              if (_currentPosition != null) {
                await _moveCameraToPos(_currentPosition!);
              }

              if (mounted) {
                setState(() => _initialViewport = null);
              }
            },
          ),

          // Top: current area name display
          CurrentAreaBar(locationName: _currentLocationName),

          // Top right: logout button
          Positioned(
            top: 10,
            right: 10,
            child: SafeArea(
              child: FloatingActionButton(
                mini: true,
                heroTag: 'logout',
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                onPressed: () => auth.signOut(),
                child: const Icon(Icons.logout),
              ),
            ),
          ),

          // Left Top: User Profile button
          Positioned(
            top: 90,
            left: 10,
            child: SafeArea(
              child: FloatingActionButton(
                mini: true,
                heroTag: 'profile',
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                ),
                child: const Icon(Icons.person),
              ),
            ),
          ),

          // Left Top: Friends button
          Positioned(
            top: 150,
            left: 10,
            child: SafeArea(
              child: FloatingActionButton(
                mini: true,
                heroTag: 'friends',
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FriendsPage()),
                ),
                child: const Icon(Icons.people),
              ),
            ),
          ),

          // Bottom right: recenter, and add pin buttons
          MapToolbar(onRecenter: _recenterMap, onAddPin: _addPin),
        ],
      ),
    );
  }
}
