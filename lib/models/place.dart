import 'package:jio_leh/models/user_pin.dart';

class Place {
  final String? id;
  final String name;
  final double latitude;
  final double longitude;
  final int pinCount;
  final List<UserPin> pins;
  final String? category;

  const Place({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.pinCount = 0,
    this.pins = const [],
    this.category,
  });

  factory Place.fromMap(Map<String, dynamic> map) {
    final rawPins = map['user_pins'] as List<dynamic>?;

    return Place(
      id: map['id'] as String?,
      name: map['name'] as String? ?? 'Unnamed place',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      pinCount: map['pin_count'] as int? ?? 0,
      pins:
          rawPins
              ?.map((pin) => UserPin.fromMap(pin as Map<String, dynamic>))
              .toList() ??
          const [],
      category: map['category'] as String?,
    );
  }
}
