import 'package:flutter/material.dart';

class MapToolbar extends StatelessWidget {
  const MapToolbar({
    super.key,
    required this.onRecenter,
    required this.onAddPin,
  });

  final VoidCallback onRecenter;
  final VoidCallback onAddPin;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'recenter',
            onPressed: onRecenter,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'addPin',
            onPressed: onAddPin,
            child: const Icon(Icons.place),
          ),
        ],
      ),
    );
  }
}
