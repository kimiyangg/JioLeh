import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jio_leh/config/map_env.dart';
import 'package:jio_leh/config/supabase_env.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'config/validate_env.dart';
/*
For this example to work, you need to provide the following dart-define values:
- MAPBOX_ACCESS_TOKEN: Your Mapbox access token.
- SUPABASE_URL: Your Supabase project URL.
- SUPABASE_ANON_KEY: Your Supabase anon key.
- MAPBOX_STYLE_URI: The Mapbox style URI you want to use (e.g., "mapbox://styles/mapbox/streets-v11").
You can provide these values when running the app using the --dart-define flag:
*/



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ValidateEnv.validateEnvironment();

  MapboxOptions.setAccessToken(MapEnv.mapboxAccessToken);

  await Supabase.initialize(
    url: SupabaseEnv.supabaseUrl,
    anonKey: SupabaseEnv.supabaseAnonKey,
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

  String currentLocationName = 'Finding your location...';
  bool isLoadingLocationName = false;

  DateTime? lastReverseGeocodeTime;
  geo.Position? lastReverseGeocodedPosition;

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

      await updateCurrentLocationName(initialPosition, force: true);
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

        await updateCurrentLocationName(position);

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
          circleColor: Colors.red.toARGB32(),
          circleStrokeColor: Colors.white.toARGB32(),
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

  Future<String> getLocationNameFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(
      'api.mapbox.com',
      '/search/geocode/v6/reverse',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'language': 'en',
        'access_token': MapEnv.mapboxAccessToken,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to get location name: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>?;

    if (features == null || features.isEmpty) {
      return 'Unknown location';
    }

    final firstFeature = features.first as Map<String, dynamic>;
    final properties = firstFeature['properties'] as Map<String, dynamic>? ?? {};
    final context = properties['context'] as Map<String, dynamic>? ?? {};

    final name = properties['name'] as String?;

    final neighborhood = context['neighborhood']?['name'] as String?;
    final locality = context['locality']?['name'] as String?;
    final district = context['district']?['name'] as String?;
    final place = context['place']?['name'] as String?;
    final region = context['region']?['name'] as String?;
    final country = context['country']?['name'] as String?;

    final area = neighborhood ??
        locality ??
        district ??
        place ??
        region ??
        name;

    if (area != null && country != null && area != country) {
      return '$area, $country';
    }

    return area ?? country ?? 'Unknown location';
  }

  Future<void> updateCurrentLocationName(
    geo.Position position, {
    bool force = false,
  }) async {
    if (isLoadingLocationName) return;

    final now = DateTime.now();

    final recentlyUpdated = lastReverseGeocodeTime != null &&
        now.difference(lastReverseGeocodeTime!).inSeconds < 20;

    final hasNotMovedMuch = lastReverseGeocodedPosition != null &&
        geo.Geolocator.distanceBetween(
              lastReverseGeocodedPosition!.latitude,
              lastReverseGeocodedPosition!.longitude,
              position.latitude,
              position.longitude,
            ) <
            50;

    if (!force && recentlyUpdated && hasNotMovedMuch) {
      return;
    }

    if (!mounted) return;

    setState(() {
      isLoadingLocationName = true;
    });

    try {
      final locationName = await getLocationNameFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;

      setState(() {
        currentLocationName = locationName;
        lastReverseGeocodeTime = now;
        lastReverseGeocodedPosition = position;
        isLoadingLocationName = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        currentLocationName = 'Unable to detect current area';
        isLoadingLocationName = false;
      });
    }
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
                pitch: 60,
              ),
              styleUri: MapEnv.mapboxStyleUri,
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
                          isLoadingLocationName
                              ? 'Finding your current area...'
                              : currentLocationName,
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