import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:supabase_flutter/supabase_flutter.dart';

const String mapboxAccessToken = String.fromEnvironment(
  'MAPBOX_ACCESS_TOKEN',
);

const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
);

const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
);

const String mapboxStyleUri = String.fromEnvironment(
  'MAPBOX_STYLE_URI',
);

void validateEnvironment() {
  final missingValues = [];

  if (mapboxAccessToken.isEmpty) {
    missingValues.add('MAPBOX_ACCESS_TOKEN');
  }

  if (supabaseUrl.isEmpty) {
    missingValues.add('SUPABASE_URL');
  }

  if (supabaseAnonKey.isEmpty) {
    missingValues.add('SUPABASE_ANON_KEY');
  }

  if (mapboxStyleUri.isEmpty) {
    missingValues.add('MAPBOX_STYLE_URI');
  }

  if (missingValues.isNotEmpty) {
    throw StateError(
      'Missing dart-define values: ${missingValues.join(', ')}',
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  validateEnvironment();

  MapboxOptions.setAccessToken(mapboxAccessToken);

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MapboxMap? map;
  CircleAnnotationManager? circleAnnotationManager;

  final supabase = Supabase.instance.client;

  geo.Position? userPosition;
  StreamSubscription<geo.Position>? positionStreamSubscription;

  bool isLoadingLocation = true;
  bool followCurrentPosition = true;

  List<Map<String, dynamic>> pinnedLocations = [];

  @override
  void initState() {
    super.initState();
    setupBackend();
    startLocationTracking();
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> setupBackend() async {
    await signInIfNeeded();
    await loadPinnedLocations();
  }

  Future<void> signInIfNeeded() async {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      await supabase.auth.signInAnonymously();
    }
  }

  Future<bool> ensureLocationPermission() async {
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return false;
    }

    geo.LocationPermission permission =
        await geo.Geolocator.checkPermission();

    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
    }

    if (permission == geo.LocationPermission.denied ||
        permission == geo.LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> startLocationTracking() async {
    try {
      final hasPermission = await ensureLocationPermission();

      if (!hasPermission) {
        if (!mounted) return;

        setState(() {
          isLoadingLocation = false;
        });

        return;
      }

      final initialPosition = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        userPosition = initialPosition;
        isLoadingLocation = false;
      });

      await enableMapboxLocationComponent();
      await moveCameraToPosition(initialPosition, zoom: 15);

      positionStreamSubscription?.cancel();

      positionStreamSubscription = geo.Geolocator.getPositionStream(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
          distanceFilter: 2,
        ),
      ).listen((position) async {
        if (!mounted) return;

        setState(() {
          userPosition = position;
        });

        if (followCurrentPosition) {
          await moveCameraToPosition(position);
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  Future<void> enableMapboxLocationComponent() async {
    if (map == null) return;

    await map!.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
      ),
    );
  }

  Future<void> moveCameraToPosition(
    geo.Position position, {
    double? zoom,
  }) async {
    if (map == null) return;

    final camera = await map!.getCameraState();

    await map!.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            position.longitude,
            position.latitude,
          ),
        ),
        zoom: zoom ?? camera.zoom,
      ),
      MapAnimationOptions(
        duration: 500,
      ),
    );
  }

  Future<void> zoomIn() async {
    if (map == null) return;

    final camera = await map!.getCameraState();

    await map!.flyTo(
      CameraOptions(
        zoom: camera.zoom + 1,
      ),
      MapAnimationOptions(
        duration: 500,
      ),
    );
  }

  Future<void> zoomOut() async {
    if (map == null) return;

    final camera = await map!.getCameraState();

    await map!.flyTo(
      CameraOptions(
        zoom: camera.zoom - 1,
      ),
      MapAnimationOptions(
        duration: 500,
      ),
    );
  }

  Future<void> savePinnedLocation({
    required double latitude,
    required double longitude,
    required String name,
    required String emoji,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await signInIfNeeded();
    }

    await supabase.from('pinned_locations').insert({
      'user_id': supabase.auth.currentUser!.id,
      'name': name,
      'emoji': emoji,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<void> loadPinnedLocations() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      await signInIfNeeded();
    }

    final data = await supabase
        .from('pinned_locations')
        .select()
        .order('created_at', ascending: false);

    if (!mounted) return;

    setState(() {
      pinnedLocations = List<Map<String, dynamic>>.from(data);
    });

    await renderPinnedLocations();
  }

  Future<void> renderPinnedLocations() async {
    if (map == null) return;

    circleAnnotationManager ??=
        await map!.annotations.createCircleAnnotationManager();

    await circleAnnotationManager!.deleteAll();

    for (final location in pinnedLocations) {
      final double latitude = (location['latitude'] as num).toDouble();
      final double longitude = (location['longitude'] as num).toDouble();

      await circleAnnotationManager!.create(
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              longitude,
              latitude,
            ),
          ),
          circleRadius: 9.0,
          circleColor: Colors.red.value,
          circleStrokeWidth: 2.0,
          circleStrokeColor: Colors.white.value,
        ),
      );
    }
  }

  Future<void> addCurrentPositionPin() async {
    try {
      final hasPermission = await ensureLocationPermission();

      if (!hasPermission) return;

      final freshPosition = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        userPosition = freshPosition;
      });

      await savePinnedLocation(
        latitude: freshPosition.latitude,
        longitude: freshPosition.longitude,
        name: "Current Position",
        emoji: "📍",
      );

      await loadPinnedLocations();
      await moveCameraToPosition(freshPosition);
    } catch (e) {
      return;
    }
  }

  Future<void> recenterToCurrentPosition() async {
    if (userPosition == null) return;

    setState(() {
      followCurrentPosition = true;
    });

    await moveCameraToPosition(userPosition!, zoom: 15);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingLocation) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final double longitude = userPosition?.longitude ?? 103.7764;
    final double latitude = userPosition?.latitude ?? 1.2966;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            MapWidget(
              viewport: CameraViewportState(
                center: Point(
                  coordinates: Position(
                    longitude,
                    latitude,
                  ),
                ),
                zoom: 15,
                bearing: 0,
                pitch: 0,
              ),
              styleUri: mapboxStyleUri,
              onMapCreated: (controller) async {
                map = controller;

                await map!.scaleBar.updateSettings(
                  ScaleBarSettings(
                    enabled: false,
                  ),
                );

                await enableMapboxLocationComponent();
                await renderPinnedLocations();

                if (userPosition != null) {
                  await moveCameraToPosition(
                    userPosition!,
                    zoom: 15,
                  );
                }
              },
            ),

            Positioned(
              right: 16,
              bottom: 32,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: "zoomIn",
                    onPressed: zoomIn,
                    child: const Icon(Icons.add),
                  ),

                  const SizedBox(height: 12),

                  FloatingActionButton(
                    heroTag: "zoomOut",
                    onPressed: zoomOut,
                    child: const Icon(Icons.remove),
                  ),

                  const SizedBox(height: 12),

                  FloatingActionButton(
                    heroTag: "recenter",
                    onPressed: recenterToCurrentPosition,
                    child: const Icon(Icons.my_location),
                  ),

                  const SizedBox(height: 12),

                  FloatingActionButton(
                    heroTag: "addPin",
                    onPressed: addCurrentPositionPin,
                    child: const Icon(Icons.place),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}