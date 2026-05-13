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
  final missingValues = <String>[];

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
  final supabase = Supabase.instance.client;

  geo.Position? userPosition;
  bool isLoadingLocation = true;

  List<Map<String, dynamic>> pinnedLocations = [];

  @override
  void initState() {
    super.initState();
    setupBackend();
    getUserLocation();
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

  Future<void> getUserLocation() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();

      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }

      if (permission == geo.LocationPermission.denied ||
          permission == geo.LocationPermission.deniedForever) {
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
        ),
      );

      setState(() {
        userPosition = position;
        isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        isLoadingLocation = false;
      });
    }
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

    setState(() {
      pinnedLocations = List<Map<String, dynamic>>.from(data);
    });
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
                  coordinates: Position(longitude, latitude),
                ),
                zoom: 15,
                bearing: 0,
                pitch: 0,
              ),
              styleUri: "mapbox://styles/kimiyang/cmp11y75m000b01s7fr3615v9",
              onMapCreated: (controller) async {
                map = controller;

                await map!.scaleBar.updateSettings(
                  ScaleBarSettings(enabled: false),
                );

                if (userPosition != null) {
                  await map!.location.updateSettings(
                    LocationComponentSettings(enabled: true),
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
                    heroTag: "addPin",
                    onPressed: () async {
                      await savePinnedLocation(
                        latitude: 1.2966,
                        longitude: 103.7764,
                        name: "NUS",
                        emoji: "🏫",
                      );

                      await loadPinnedLocations();
                    },
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