import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/app.dart';
import 'package:jio_leh/config/map_env.dart';
import 'package:jio_leh/config/supabase_env.dart';
import 'package:jio_leh/config/validate_env.dart';

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
