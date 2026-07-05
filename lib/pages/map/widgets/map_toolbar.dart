import 'package:flutter/material.dart';

class MapToolbar extends StatelessWidget {
  const MapToolbar({
    super.key,
    required this.onRecenter,
  });

  final VoidCallback onRecenter;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'recenter',
            onPressed: onRecenter,
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
