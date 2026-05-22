class MapEnv {
  static const String mapboxStyleUri = String.fromEnvironment(
    'MAPBOX_STYLE_URI',
  );

  static const String mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
  );
}