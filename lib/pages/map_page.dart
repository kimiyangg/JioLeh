import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/config/map_env.dart';
import 'package:jio_leh/models/pinned_location.dart';
import 'package:jio_leh/services/auth_services.dart';
import 'package:jio_leh/services/geocoding_services.dart';
import 'package:jio_leh/services/location_services.dart';
import 'package:jio_leh/services/pin_services.dart';

class MapPage extends StatefulWidget{
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Initialize services
  final auth = AuthServices();

  // The term late means the variable will be initialized later, but before it's used.
  // This allows us to use the auth instance to create the pinServices instance
  // without running into initialization order issues.
  late final _locationPins = PinServices(Supabase.instance.client, auth);
  final _geocoding = GeoCodingServices();

  // Map state and controls
  MapboxMap? _map;
  CircleAnnotationManager? _pinsManager;
  
  // User location state and controls
  geo.Position? _currentPosition;
  late final _location = LocationService();

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

  void dispose() {
    _location.dispose();
    super.dispose();
  }

  // Main boot sequence to initialize location, map, and pins
  Future<void> _booting() async {
    await auth.signInIfNeeded();
    await _reloadPins();
    await _startLocationTracking();
  }

  // Map Helper Methods
  Future<void> _enableMapboxLocationComponent() {
    BLABLABLABLA IMD OING WORKKKKk
  }

  Future<void> _moveCameraToPos(geo.Position position){
    // TO-DO
  }

  Future<void> _zoomIn() {
    // TO-DO
  }

  Future<void> _zoomOut() {
    // TO-DO
  }
  
  // Location Helper Methods
  Future<void> _startLocationTracking() {
    // TO-DO
  }

  void _onLocationUpdate(geo.Position position) {
    // TO-DO
  }

  Future<void> _recenterMap() {
    // TO-DO
  }

  // Area Name Helper Methods
  Future<void> _updateLocationName(geo.Position position) {
    // TO-DO
  }

  // Pin Helper Methods
  Future<void> _reloadPins() async {
    final pins = await _locationPins.loadPinnedLocations();
    if (!mounted) return;
    setState(() => _pinnedLocations = pins);
    await _renderPinnedLocations();
  }


  Future<void> _addPin() {
    // TO-DO
  }

  Future<void> _renderPinnedLocations() async {
    if (_map == null) return;

    _pinsManager ??=
        await _map!.annotations.createCircleAnnotationManager();

    await _pinsManager!.deleteAll();

    for (final location in _pinnedLocations) {
      await _pinsManager!.create(
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              location.longitude,
              location.latitude,
            ),
          ),
          circleRadius: 9.0,
          circleColor: Colors.red.toARGB32(),
          circleStrokeColor: Colors.white.toARGB32(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final double longitude = _currentPosition?.longitude ?? 103.7764;
    final double latitude = _currentPosition?.latitude ?? 1.2966;

    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            viewport: CameraViewportState(
              center: Point(coordinates: Position(longitude, latitude)),
              zoom: 15,
              bearing: 0,
              pitch: 60,
            ),
            styleUri: MapEnv.mapboxStyleUri,
            onMapCreated: (controller) async {
              _map = controller;

              await _map!.scaleBar.updateSettings(
                ScaleBarSettings(enabled: false),
              );

              await _enableMapboxLocationComponent();
              await _renderPinnedLocations();

              if (_currentPosition != null) {
                await _moveCameraToPos(_currentPosition!);
              }
            },
          ),

          // Top: current area name display
          Positioned(
            left: 20,
            right: 50,
            top: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color.fromARGB(255, 10, 250, 186),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentLocationName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom right: zoom in/out, recenter, and add pin buttons
          Positioned(
            right: 16,
            bottom: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'recenter',
                  onPressed: _recenterMap,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'addPin',
                  onPressed: _addPin,
                  child: const Icon(Icons.place),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}