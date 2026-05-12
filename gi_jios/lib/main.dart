import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  MapboxOptions.setAccessToken(
    "pk.eyJ1Ijoia2ltaXlhbmciLCJhIjoiY21wMGxhbHFpMWlzdjJ4b2ZzcWo3cjY5ZCJ9.kLYgUejkShnMvdT-K3NaWw",
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            MapWidget(
              viewport: CameraViewportState(
                center: Point(
                  coordinates: Position(-98.0, 39.5),
                ),
                zoom: 2,
                bearing: 0,
                pitch: 0,
              ),
              styleUri: "mapbox://styles/kimiyang/cmp11y75m000b01s7fr3615v9",
              onMapCreated: (controller) {
                map = controller;
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}