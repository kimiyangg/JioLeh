class NearbyPlace {
  final String placeId;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;

  const NearbyPlace({
    required this.placeId,
    required this.name,
    required this.latitude,
    required this.longitude,
    // Given that address might not be always available
    this.address,
  });

  factory NearbyPlace.fromMap(Map<String, dynamic> map) {
    final location = map['location'] as Map<String, dynamic>? ?? {};
    final displayName = map['displayName'] as Map<String, dynamic>?;

    return NearbyPlace(
      placeId: map['id'] as String? ?? '',
      name: displayName?['text'] as String? ?? 'Unnamed place',
      latitude: (location['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (location['longitude'] as num?)?.toDouble() ?? 0,
      address: map['formattedAddress'] as String?,
    );
  }


}