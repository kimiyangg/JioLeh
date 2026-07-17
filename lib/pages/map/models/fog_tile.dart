class FogTile {
  const FogTile(this.x, this.y);

  factory FogTile.fromLatLng(double latitude, double longitude) {
    return FogTile(
      (longitude / tileSizeDeg).floor(),
      (latitude / tileSizeDeg).floor(),
    );
  }

  factory FogTile.fromMap(Map<String, dynamic> map) {
    return FogTile(map['tile_x'] as int, map['tile_y'] as int);
  }

  static const double tileSizeDeg = 0.000225;

  final int x;
  final int y;

  double get west => x * tileSizeDeg;
  double get east => (x + 1) * tileSizeDeg;
  double get south => y * tileSizeDeg;
  double get north => (y + 1) * tileSizeDeg;

  List<FogTile> neighbours() => [
        for (var dx = -1; dx <= 1; dx++)
          for (var dy = -1; dy <= 1; dy++) FogTile(x + dx, y + dy),
      ];

  @override
  bool operator ==(Object other) =>
      other is FogTile && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}
