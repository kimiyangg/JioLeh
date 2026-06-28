import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:jio_leh/config/map_env.dart';

import 'package:jio_leh/models/place.dart';
import 'package:jio_leh/models/user_pin.dart';

import 'package:jio_leh/pages/map/widgets/location_permission_dialog.dart';
import 'package:jio_leh/pages/map/widgets/current_area_bar.dart';
import 'package:jio_leh/pages/map/widgets/map_toolbar.dart';
import 'package:jio_leh/pages/map/location_customize_page.dart';

import 'package:jio_leh/pages/map/renders/map_pins.dart';

import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/pages/map/add_pin.dart';
import 'package:jio_leh/pages/map/map_page_model.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.model});

  final MapPageModel model;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Map view state. The data (location, places) lives in the model.
  MapboxMap? _map;
  MapPins? _pins;
  Timer? _viewportReload;
  ViewportState? _initialViewport;
  List<Place>? _renderedPlaces;
  bool _didBoot = false;

  MapPageModel get _model => widget.model;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didBoot) return;
    _didBoot = true;

    _model.addListener(_onModelChanged);
    _boot();
  }

  @override
  void dispose() {
    _viewportReload?.cancel();
    _model.removeListener(_onModelChanged);
    super.dispose();
  }

  Future<void> _boot() async {
    try {
      await _model.start();
    } catch (e) {
      if (!mounted) return;
      await _showLocationErrorDialog(e);
    }
  }

  void _onModelChanged() {
    if (!mounted) return;

    // First fix: seed the initial viewport so the map opens at the user.
    if (_map == null &&
        _initialViewport == null &&
        _model.currentPosition != null) {
      _initialViewport = _viewportFor(_model.currentPosition!);
    }

    // Re-render pins only when the places list itself changed.
    if (!identical(_renderedPlaces, _model.places)) {
      _renderedPlaces = _model.places;
      _pins?.render(_model.places);
    }

    setState(() {});
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
        locationPuck: LocationPuck(
          locationPuck3D: LocationPuck3D(
            modelUri: "asset://assets/models/Adventurer_static.glb",
            modelScale: [25,25,25]
          )
        )
      ), // the ring/puck rotates when the user rotates (changes wrt bearing)
    );
  }

  Future<void> _initMapStyleSettings() async {
    if (_map == null) return;

    _map!.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    // Position the compass in the gap left beside the location bar
    _map!.compass.updateSettings(
      CompassSettings(
        position: OrnamentPosition.BOTTOM_LEFT,
        marginLeft: 15,
        marginBottom: 120,
      ),
    );
  }

  ViewportState _viewportFor(geo.Position position) {
    return CameraViewportState(
      center: Point(
        coordinates: Position(position.longitude, position.latitude),
      ),
      zoom: 15,
      bearing: 0,
      pitch: 60,
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

  Future<void> _recenterMap() async {
    final position = _model.currentPosition;
    if (position == null) return;
    await _moveCameraToPos(position);
  }

  void _onMapIdle(MapIdleEventData _) {
    _viewportReload?.cancel();
    _viewportReload = Timer(
      const Duration(milliseconds: 300),
      _reloadVisiblePlaces,
    );
  }

  Future<void> _reloadVisiblePlaces() async {
    final map = _map;
    if (map == null) return;

    final camera = await map.getCameraState();
    final bounds = await map.coordinateBoundsForCamera(
      CameraOptions(
        center: camera.center,
        zoom: camera.zoom,
        bearing: camera.bearing,
        pitch: camera.pitch,
        padding: camera.padding,
      ),
    );

    final southwest = bounds.southwest.coordinates;
    final northeast = bounds.northeast.coordinates;

    await _model.reloadPlacesInBounds(
      west: southwest.lng.toDouble(),
      south: southwest.lat.toDouble(),
      east: northeast.lng.toDouble(),
      north: northeast.lat.toDouble(),
    );
  }

  Future<void> _showLocationErrorDialog(Object error) async {
    await showLocationErrorDialog(
      context: context,
      error: error,
      locationService: ServiceProvider.of(context)!.location,
      onRetry: () => _boot(),
    );
  }

  Future<void> _showPlace(Place place) async {
    final pin = _primaryPinFor(place);
    final pinType = PinType.values.firstWhere(
      (type) => type.emoji == (pin?.emoji ?? '\u{1F4CD}'),
      orElse: () => PinType.restaurant,
    );

    try {
      final photoUrls = await _model.photoUrls(pin?.photoPaths ?? const []);

      if (!mounted) return;

      await showLocationCustomizePage(
        context,
        pinType,
        initialCustomization: LocationCustomization(
          pinType: pinType,
          formalName: place.name,
          name: pin?.customName ?? '',
          rating: pin?.rating ?? 0,
          review: pin?.review ?? '',
          isPrivate: pin?.isPrivate,
          photoUrls: photoUrls,
        ),
        isReadOnly: true,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load location photos: $error')),
      );
    }
  }

  UserPin? _primaryPinFor(Place place) {
    return place.pins.isEmpty ? null : place.pins.first;
  }

  @override
  Widget build(BuildContext context) {
    if (_model.isLoadingLocation) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            viewport: _initialViewport,
            styleUri: MapEnv.mapboxStyleUri,
            onMapIdleListener: _onMapIdle,
            onMapCreated: (controller) async {
              _map = controller;
              _pins = MapPins(
                controller,
                onPinTapped: (place) {
                  _showPlace(place);
                },
              );

              await _initMapStyleSettings();
              await _enableMapboxLocationComponent();
              _renderedPlaces = _model.places;
              await _pins!.render(_model.places);

              if (_model.currentPosition != null) {
                await _moveCameraToPos(_model.currentPosition!);
              }

              if (mounted) {
                setState(() => _initialViewport = null);
              }
            },
          ),

          // Top: current area name display
          CurrentAreaBar(locationName: _model.locationName),

          // Bottom right: recenter, and add pin buttons
          MapToolbar(
            onRecenter: _recenterMap,
            onAddPin: () => addPin(context, _model),
          ),
        ],
      ),
    );
  }
}
