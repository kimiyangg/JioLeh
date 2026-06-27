/// A single place suggestion returned from Mapbox forward geocoding.
///
/// Used to power the "Formal location name" autocomplete. Only [name] is shown
/// as the saved value; [placeFormatted] is an optional secondary line (such as
/// the city/country) and [latitude]/[longitude] are kept only if Mapbox returns
/// them, in case a future feature needs the coordinates.
class PlaceSuggestion {
  final String name;
  final String? placeFormatted;
  final double? latitude;
  final double? longitude;

  const PlaceSuggestion({
    required this.name,
    this.placeFormatted,
    this.latitude,
    this.longitude,
  });

  /// Builds a [PlaceSuggestion] from a single Mapbox geocoding v6 feature.
  factory PlaceSuggestion.fromFeature(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>? ?? {};
    final coordinates = properties['coordinates'] as Map<String, dynamic>?;

    return PlaceSuggestion(
      name: properties['name'] as String? ?? 'Unknown place',
      placeFormatted: properties['place_formatted'] as String?,
      latitude: (coordinates?['latitude'] as num?)?.toDouble(),
      longitude: (coordinates?['longitude'] as num?)?.toDouble(),
    );
  }
}
