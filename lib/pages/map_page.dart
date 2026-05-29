import 'dart:typed_data';
import 'dart:ui' as ui;

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

import 'package:jio_leh/widgets/location_permission_dialog.dart';
import 'package:jio_leh/widgets/current_area_bar.dart';
import 'package:jio_leh/widgets/toolbar.dart';


class MapPage extends StatefulWidget{
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  static const _pinTypeOptions = [
    _PinTypeOption(name: "Restaurant", emoji: "🍽️"),
    _PinTypeOption(name: "Gym", emoji: "🏋"),
    _PinTypeOption(name: "Hotel", emoji: "🏨"),
    _PinTypeOption(name: "Toilet", emoji: "🚽"),
  ];

  // stores already created emoji images so app dont redraw the same emoji agn and agn
  final Map<String, Uint8List> _emojiImageCache = {};


  // Initialize services
  final auth = AuthServices();

  // The term late means the variable will be initialized later, but before it's used.
  // This allows us to use the auth instance to create the pinServices instance
  // without running into initialization order issues.
  late final _locationServicePins = PinServices(Supabase.instance.client, auth);
  final _geocoding = GeoCodingServices();

  // Map state and controls
  MapboxMap? _map;
  PointAnnotationManager? _pinsManager;
  ViewportState? _initialViewport;
  
  // User location state and controls
  geo.Position? _currentPosition;
  late final _locationService = LocationServices();

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
    await auth.signInIfNeeded();
    await _reloadPins();
    await _startLocationTracking();
  }

  // Map Helper Methods
  Future<void> _enableMapboxLocationComponent() async {
    if (_map == null) return; // _map only assigned aft onMapCreated runs. this prevent crash 
    await _map!.location.updateSettings(// access and update location component settings 
      LocationComponentSettings( // how user location marker shld behave 
        enabled: true, // current loc can be seen 
        pulsingEnabled: true, // pulsing animation ard user loc 
        showAccuracyRing: true, // show GPS accuracy area 
        puckBearingEnabled: true,), // the ring/puck rotates when the user rotates (changes wrt bearing)
      );
  }

  Future<void> _moveCameraToPos(geo.Position position) async{
    if (_map == null) return; // prevent crash if method called too early 
    await _map!.easeTo( // easeTo means the camera moves smoothly to current pos
      CameraOptions(
        center: Point(coordinates: Position(position.longitude, position.latitude,),
        ),
        zoom: 15, bearing: 0, pitch: 60,), // stay constant w earlier settings:
        // 15 zoom == street lvl, 0 bearing == north facing, 60 pitch == 3D view 
        MapAnimationOptions(duration: 1000, startDelay: 0,), // animate movement over 1000 millisec
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
        onLocationUpdate: _onLocationUpdate
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
    _geocoding.fetchAreaName(
      latitude: position.latitude,
      longitude: position.longitude,
    ).then((name) {
      if (!mounted) return;
      setState(() => _currentLocationName = name);
    });
  }

  // Pin Helper Methods
  Future<void> _reloadPins() async {
    final pins = await _locationServicePins.loadPinnedLocations();
    if (!mounted) return;
    setState(() => _pinnedLocations = pins);
    await _renderPinnedLocations();
  }


  Future<void> _addPin() async { // function runs when user press add pin button
    final selectedType = await _showPinTypePicker(); // page comes up, wait for user to tap 
    if (selectedType == null) return; // if nvr choose, return nth 
    
    if (!mounted) return; // stops if page not active 

    final customName = await _showLocationCustomiseSheet(selectedType);

    if (!mounted) return; // in case user left page while sheet open 

    final position = _currentPosition; // save current location for pinning

    if (position == null) return; // stops if location unknown 

    await _locationServicePins.savePinnedLocation(
      PinnedLocation(latitude: position.latitude,
       longitude: position.longitude,
        name: customName?.trim() ?? '', // if user close page early, return ''
        // else, return wtv he typed in 
         emoji: selectedType.emoji)); // still save the emoji 
    
    await _reloadPins();
  }
  
  // this is AI-generated UI when user first click add location and choose frm the types 
  Future<_PinTypeOption?> _showPinTypePicker() { // ? means may return null, or the selected option
  return showModalBottomSheet<_PinTypeOption>(  // shows bottom sheet,
  // _PinTypeOption mean can only return 1 pin type 
    context: context,
    showDragHandle: true, // drag handle on top of sheet 
    builder: (context) {
      return SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.5, // makes sheet half screen ht 
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose location type',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2, // 2 column button grid 
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.4,
                    children: [
                      for (final option in _pinTypeOptions) 
                      // loops through restaurant, ...
                        FilledButton( // one button per option 
                          onPressed: () => Navigator.pop(context, option),
                          child: Text(
                            '${option.emoji} ${option.name}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// this is AI-generated UI when user chose loc type and now customising name 
Future<String?> _showLocationCustomiseSheet(_PinTypeOption selectedType) async {
  final controller = TextEditingController();

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.95,
        child: SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${selectedType.emoji} Customise location name',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Location name',
                      hintText: 'Example: My favourite prata place',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      Navigator.pop(context, value);
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context, controller.text);
                    },
                    child: const Text('Enter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<Uint8List> _emojiImageFor(String emoji) async {
  final cachedImage = _emojiImageCache[emoji];

  if (cachedImage != null) {
    return cachedImage;
  }

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  // emoji size. change fontSize to make bigger/smaller 
  const imageSize = 128.0;
  const fontSize = 92.0;

  // draw the emoji like a text 
  final textPainter = TextPainter(
    text: TextSpan(
      text: emoji,
      style: const TextStyle(fontSize: fontSize),
    ),
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();

  final offset = Offset(
    (imageSize - textPainter.width) / 2,
    (imageSize - textPainter.height) / 2,
  );

  // paints emoji onto invisible canvas 
  textPainter.paint(canvas, offset);

  final picture = recorder.endRecording();
  final image = await picture.toImage(
    // the canvas turn into an image 
    imageSize.toInt(),
    imageSize.toInt(),
  );

  final byteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );

  final emojiImage = byteData!.buffer.asUint8List(); 
  // converts image into the format Mapbox needs 
  _emojiImageCache[emoji] = emojiImage;

  return emojiImage;
}

// draws the newest pin first from supabase, skips overlapping ones 
Future<void> _renderPinnedLocations() async {
  if (_map == null) return;

  _pinsManager ??= await _map!.annotations.createPointAnnotationManager();

  await _pinsManager!.deleteAll();

  final renderedLocations = <PinnedLocation>[]; // keeps track of pins alr shown on map 

  for (final location in _pinnedLocations) {
    final alreadyRenderedNearby = renderedLocations.any( 
      // checks if this pin is close to another pin already drawn 
      (renderedLocation) => _isNearbyLocation(
        location,
        renderedLocation,
      ),
    );

    if (alreadyRenderedNearby) continue;
    // if pins are nearby, skip pinning so no overlapping of names 

    renderedLocations.add(location);
    // else, rmb it and draw it 

    final emojiImage = await _emojiImageFor(location.emoji);
    final name = location.name.trim();

    await _pinsManager!.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            location.longitude,
            location.latitude,
          ),
        ),
        image: emojiImage,
        iconSize: 0.55,
        iconAnchor: IconAnchor.BOTTOM,
        textField: name.isEmpty ? null : name,
        textSize: 15,
        textOffset: [0, 0.8],
        textAnchor: TextAnchor.TOP,
        textColor: Colors.black.toARGB32(),
        textHaloColor: Colors.white.toARGB32(),
        textHaloWidth: 2,
      ),
    );
  }
}

// takes in 2 location. if the diff in longitude and latitude less than 20m, it is
// same place. This is a helper method for renderPinnedLocation()
bool _isNearbyLocation(
  PinnedLocation firstLocation,
  PinnedLocation secondLocation,
) {
  const tolerance = 0.0002; // loc within 20m is the "same" place 
  

  final latitudeDifference =
      (firstLocation.latitude - secondLocation.latitude).abs();

  final longitudeDifference =
      (firstLocation.longitude - secondLocation.longitude).abs();

  return latitudeDifference < tolerance &&
      longitudeDifference < tolerance;
}

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            viewport: _initialViewport,
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

              if (mounted) {
                setState(() => _initialViewport = null);
              }
            },
          ),
          
          // Top: current area name display
          CurrentAreaBar(
            locationName: _currentLocationName
          ),

          // Bottom right: zoom in/out, recenter, and add pin buttons
          MapToolbar(
            onRecenter: _recenterMap,
            onAddPin: _addPin,
          ),
        ],
      ),
    );
  }
}

// each location type e.g. gym will store its corresponding set emoji 
//and the customised name from user 
class _PinTypeOption {
  final String emoji;
  final String name;

  const _PinTypeOption({
    required this.name,
    required this.emoji,
  });
}
